# encoding: utf-8

# ------------------------------------------------------------------------------
# Copyright (c) 2006 Novell, Inc. All Rights Reserved.
#
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of version 2 of the GNU General Public License as published by the
# Free Software Foundation.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program; if not, contact Novell, Inc.
#
# To contact Novell about this file by physical or electronic mail, you may find
# current contact information at www.novell.com.
# ------------------------------------------------------------------------------

# File:	include/openvas-security-scanner/wizards.ycp
# Package:	Configuration of openvas-security-scanner
# Summary:	Wizards definitions
# Authors:	Felix Wolfsteller <felix.wolfsteller@intevation.de>
#
# $**Id$
module Yast
  module OpenvasSecurityScannerWizardsInclude
    def initialize_openvas_security_scanner_wizards(include_target)
      Yast.import "UI"

      textdomain "openvas-security-scanner"

      Yast.import "Sequencer"
      Yast.import "Wizard"

      Yast.include include_target, "openvas-security-scanner/complex.rb"
      Yast.include include_target, "openvas-security-scanner/dialogs.rb"
    end

    # Main dialog workflow of the openvas-security-scanner configuration.
    #
    # @return Sequence result.
    def MainSequence
      aliases = {
        "conf"           => [lambda { ScannerConfigurationDialog() }, true],
        "feed_sync"      => [lambda { SyncDialog() }, true],
        "enter_gsf"      => [lambda { EnterGSFLocationDialog() }, true],
        "activate_gsf"   => [lambda { ActivateGSFDialog() }, true],
        "deactivate_gsf" => [lambda { DeactivateGSFDialog() }, true]
      }

      sequence = {
        "ws_start"       => "conf",
        "conf"           => {
          :abort          => :abort,
          :next           => :next,
          :feedsync_now   => "feed_sync",
          :activate_gsf   => "enter_gsf",
          :deactivate_gsf => "deactivate_gsf",
          :no_feed        => :no_feed,
          :fetch_new      => :fetch_new,
          :write          => :write
        },
        "feed_sync"      => { :abort => :abort, :next => "conf" },
        "enter_gsf"      => { :abort => "conf", :next => "activate_gsf" },
        "activate_gsf"   => { :abort => "conf", :next => "conf" },
        "deactivate_gsf" => { :abort => "conf", :next => "conf" }
      }

      ret = Sequencer.Run(aliases, sequence)

      deep_copy(ret)
    end

    # Workflow of the whole module
    # @return sequence result
    def OpenvasSecurityScannerSequence
      aliases = {
        "read"       => [lambda { ReadDialog() }, true],
        "adduser"    => lambda { AddUserDialog() },
        "main"       => lambda { MainSequence() },
        "feed_fetch" => lambda { FetchFeedDialog() },
        "enter_gsf"  => lambda { EnterGSFLocationDialog() },
        "fetch_new"  => lambda { FetchFeedDialog() },
        "no_feed"    => lambda { DisableOpenVASDialog() },
        "write"      => [lambda { WriteDialog() }, true]
      }

      sequence = {
        "ws_start"   => "read",
        "read"       => {
          :abort   => :abort,
          :addUser => "adduser",
          :next    => "main"
        },
        "adduser"    => { :abort => :abort, :next => "main" },
        "main"       => {
          :abort        => :abort,
          :feedsync_now => "feed_fetch",
          :activate_gsf => "enter_gsf",
          :fetch_new    => "fetch_new",
          :next         => "write",
          :no_feed      => "no_feed",
          :write        => "write"
        },
        "enter_gsf"  => { :abort => "main", :next => "main" },
        "feed_fetch" => { :abort => "main", :next => "main" },
        "fetch_new"  => { :abort => "main", :next => "write" },
        "no_feed"    => { :abort => "main", :next => "write" },
        "write"      => { :abort => :abort, :next => :next }
      }

      Wizard.CreateDialog

      ret = Sequencer.Run(aliases, sequence)

      UI.CloseDialog
      deep_copy(ret)
    end
  end
end
