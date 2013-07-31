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

# File:	clients/openvas-security-scanner.ycp
# Package:	Configuration of openvas-security-scanner
# Summary:	Main file
# Authors:	Felix Wolfsteller <felix.wolfsteller@intevation.de>
#
# $**Id$
#
# Main file for openvas-security-scanner configuration. Uses all other files.
module Yast
  class OpenvasSecurityScannerClient < Client
    def main
      Yast.import "UI"

      #**
      # <h3>Configuration of openvas-security-scanner</h3>

      textdomain "openvas-security-scanner"

      # The main ()
      Builtins.y2milestone("----------------------------------------")
      Builtins.y2milestone("OpenVAS Security Scanner module started")

      Yast.import "Progress"
      Yast.import "Report"
      Yast.import "Summary"

      Yast.import "CommandLine"

      Yast.include self, "openvas-security-scanner/wizards.rb"

      @cmdline_description = {
        "id"         => "openvas-security-scanner",
        "help"       => _("Configuration of OpenVAS Security Scanner"),
        "guihandler" => fun_ref(
          method(:OpenvasSecurityScannerSequence),
          "any ()"
        ),
        "initialize" => fun_ref(
          OpenvasSecurityScanner.method(:Read),
          "boolean ()"
        ),
        "finish"     => fun_ref(
          OpenvasSecurityScanner.method(:Write),
          "boolean ()"
        ),
        "actions"    => {},
        "options"    => {},
        "mappings"   => {}
      }

      # Main ui function
      @ret = nil

      @ret = CommandLine.Run(@cmdline_description)
      Builtins.y2debug("ret=%1", @ret)

      # Finish
      Builtins.y2milestone("OpenVAS Security Scanner module finished")
      Builtins.y2milestone("----------------------------------------")

      deep_copy(@ret) 

      # EOF
    end
  end
end

Yast::OpenvasSecurityScannerClient.new.main
