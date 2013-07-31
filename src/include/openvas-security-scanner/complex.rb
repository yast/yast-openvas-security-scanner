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

# File:	include/openvas-security-scanner/complex.ycp
# Package:	Configuration of openvas-security-scanner
# Summary:	Dialogs definitions
# Authors:	Felix Wolfsteller <felix.wolfsteller@intevation.de>
#
# $**Id$
module Yast
  module OpenvasSecurityScannerComplexInclude
    def initialize_openvas_security_scanner_complex(include_target)
      textdomain "openvas-security-scanner"

      Yast.import "Label"
      Yast.import "Popup"
      Yast.import "Wizard"
      Yast.import "Confirm"
      Yast.import "OpenvasSecurityScanner"


      Yast.include include_target, "openvas-security-scanner/helps.rb"
    end

    # Read settings dialog
    # @return `abort if aborted and `next otherwise
    def ReadDialog
      Wizard.RestoreHelp(Ops.get_string(@HELPS, "read", ""))
      #OpenvasSecurityScanner::SetAbortFunction(PollAbort);
      return :abort if !Confirm.MustBeRoot
      ret = OpenvasSecurityScanner.Read
      # Check if at least one user exist, if not, forward to user creation page
      if ret
        if OpenvasSecurityScanner.CheckUserExists == true
          return :next
        else
          return :addUser
        end
      else
        return :abort
      end
    end

    # Write settings dialog
    # @return `abort if aborted and `next otherwise
    def WriteDialog
      Wizard.RestoreHelp(Ops.get_string(@HELPS, "write", ""))
      #OpenvasSecurityScanner::SetAbortFunction(PollAbort);
      ret = OpenvasSecurityScanner.Write
      ret ? :next : :abort
    end


    # Feed fetching "dialog"
    # @return `abort if aborted and `next otherwise
    def FetchFeedDialog
      Wizard.RestoreHelp(Ops.get_string(@HELPS, "fetchfeed", ""))
      ret = OpenvasSecurityScanner.FetchFeed
      ret ? :next : :abort
    end

    # Feed Synchronization "dialog"
    # @return `abort if aborted and `next otherwise
    def SyncDialog
      Wizard.RestoreHelp(Ops.get_string(@HELPS, "fetchfeed", ""))
      ret = OpenvasSecurityScanner.SyncWithFeed
      ret ? :next : :abort
    end

    # Greenbone Security Feed Activation "dialog"
    # @return `abort if aborted and `next otherwise
    def ActivateGSFDialog
      Wizard.RestoreHelp(Ops.get_string(@HELPS, "activategsf", ""))
      ret = OpenvasSecurityScanner.ActivateGSF
      ret ? :next : :abort
    end
  end
end
