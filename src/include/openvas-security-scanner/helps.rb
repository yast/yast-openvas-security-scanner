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

# File:	include/openvas-security-scanner/helps.ycp
# Package:	Configuration of openvas-security-scanner
# Summary:	Help texts of all the dialogs
# Authors:	Felix Wolfsteller <felix.wolfsteller@intevation.de>
#
# $**Id$
module Yast
  module OpenvasSecurityScannerHelpsInclude
    def initialize_openvas_security_scanner_helps(include_target)
      textdomain "openvas-security-scanner"

      # All helps are here
      @HELPS = {
        # Help for main dialog
        "configuration"  => "<p><b><big>" +
          _("OpenVAS Security Scanner Configuration") + "</big></b>" +
          # Disable OpenVAS Security Scanner
          "<p><b>" +
          _("Disable OpenVAS Security Scanner") + "</b>: " +
          _(
            "Select \"Disable OpenVAS Security Scanner\" to switch off the OpenVAS Security Scanner Service. "
          ) +
          _(
            "The datastores for Network Vulnerabilities (NVTs) will be deleted. This might take some time."
          ) +
          # Enable and use OpenVAS NVT Feed
          "</p><p><b>" +
          _("Enable and use OpenVAS NVT Feed") + "</b>: " +
          _(
            "Select \"Enable and use OpenVAS NVT Feed\" to switch on the OpenVAS Security Scanner with the OpenVAS NVT Feed. "
          ) +
          _(
            "The free-of-charge OpenVAS NVT Feed delivers the latest Network Vulnerability Tests (NVTs) with volunteer-based Quality Assurance. The NVT synchronisation uses RSYNC protocol. Please visit <tt>http://www.openvas.org/</tt> for more information."
          ) +
          _(
            "Previous NVT datastores will be deleted before the initial synchronization is executed. This might take some time. "
          ) +
          # Enable and use Greenbone Security Feed
          "</p><p><b>" +
          _("Enable and use Greenbone Security Feed") + "</b>: " +
          _(
            "Select \"Enable and use Greenbone Security Feed\" to switch on the OpenVAS Security Scanner with the Greenbone Security Feed.<br>"
          ) +
          _(
            "Note that this option is only available if you obtained and activated an access key for the Greenbone Security Feed. "
          ) +
          _(
            "The subscription-based Greenbone Security Feed assures Network Vulnerability Tests (NVTs) of consistent quality, high availability and professional support. "
          ) +
          _("The NVT synchronisation uses SSH-secured RSYNC protocol. ") +
          _(
            "Previous NVT datastores will be deleted. This might take some time."
          ) +
          # Activate Greenbone Security Feed Subscription
          "</p><p><b>" +
          _("Activate Greenbone Security Feed Subscription") + "</b>: " +
          _(
            "To obtain a access key for the Greenbone Security Feed, please visit <tt>http://greenbone.net/order/</tt>. "
          ) +
          _(
            "Click on \"Activate Greenbone Security Feed\" and enter the path to the obtained access key files. "
          ) +
          _(
            "The access key and synchronization script will then be installed and you can choose the <b>\"Use Greenbone Security Feed\"</b> option to use the OpenVAS Security Scanner with this feed."
          ) +
          # Deactivate Greenbone Security Feed Subscription
          "</p><p><b>" +
          _("Deactivate Greenbone Security Feed Subscription") + "</b>: " +
          _(
            "This option is only available if you have previously activated your Greenbone Security Feed Subscription. "
          ) +
          _(
            "If you select this option, previous NVT datastores, NVT selections and other feed related files will be deleted. This might take some time."
          ) +
          # Synchronize with Feed now
          "</p><p><b>" +
          _("Synchronize with Feed now") + "</b>: " +
          _(
            "Will immediately start a synchronize with the selected feed. Note that this option is not available if you just changed the feed. "
          ) +
          # Do a daily feed synchronization
          "</p><p><b>" +
          _("Do a daily feed synchronization") + "</b>: " +
          _(
            "Will enable the daily feed synchronization with a cron job, if a feed was chosen and the service is enabled. Note that the openvas scanner service has to be restarted to be able to use the newly fetched NVTs."
          ) +
          # Next
          "</p><p><b>" +
          _("Next") + "</b>: " +
          _("Click on \"Next\" to synchronize with a newly chosen feed.") + "</p>",
        # Help for the Activate Greenbone Security Feed dialog
        "activategsf"    => "<p><b><big>" +
          _("Activate Greenbone Security Feed") + "</big></b>" + "<p>" +
          _(
            "If you already have obtained an access key, provide it in full text in the text field or click on \"Import from file\" and chose the path to it."
          ) + "</p><p>" +
          _(
            "If you do not have an access key to the Greenbone Security Feed, please visit <tt>http://greenbone.net/order/</tt> to obtain one. "
          ) +
          _(
            "If you chose to provide the key in full text, the key might be base64 encoded. "
          ) +
          _(
            "The access key and synchronization script will then be installed and you can choose the <b>\"Use Greenbone Security Feed\"</b> option."
          ) + "</p>",
        # Help for the Deactivate Greenbone Security Feed dialog
        "deactivategsf"  => "<p><b><big>" +
          _("Deactivate Greenbone Security Feed") + "</big></b>" + "<p>" +
          _(
            "The access key, the Feed synchronization script and the NVT datastores will be deleted."
          ) + "</p></p>",
        # Read dialog help 1/2
        "read"           => _(
          "<p><b><big>Initializing openvas-security-scanner Configuration</big></b><br>\nPlease wait...<br></p>\n"
        ) +
          # Read dialog help 2/2
          _(
            "<p><b><big>Aborting Initialization:</big></b><br>\nSafely abort the configuration utility by pressing <b>Abort</b> now.</p>\n"
          ),
        # Write dialog help 1/2
        "write"          => _(
          "<p><b><big>Saving openvas-security-scanner Configuration</big></b><br>\nPlease wait...<br></p>\n"
        ) +
          # Write dialog help 2/2
          _(
            "<p><b><big>Aborting Saving:</big></b><br>\n" +
              "Abort the save procedure by pressing <b>Abort</b>.\n" +
              "An additional dialog informs whether it is safe to do so.\n" +
              "</p>\n"
          ),
        "disableopenvas" => "<p><b><big>" +
          _("Disabling the OpenVAS Security Scanner Service") + "</big></b><br>" + "<p>" +
          _(
            "The service will be stopped and not start automatically after a reboot. "
          ) +
          _(
            "The NVT datastores will be deleted, which might take some time. Click abort to abort this action."
          ) + "</p></p>",
        "fetchfeed"      => "<p><b><big>" + _("Fetching a NVT Feed") + "</big></b><br>" + "<p>" +
          _("Before fetching the chosen feed, ") +
          _(
            "previous NVT datastores will be deleted, which might take some time. "
          ) +
          _(
            "Note that in order to synchronize with a feed, the scanner service has to be stopped. It will be restarted once the synchronization is finished. "
          ) +
          _("Click <b>abort</b> to abort this action.") + "</p></p>",
        "adduser"        => _(
          "<p><b><big>Add User to OpenVAS Security Scanner</big></b></br>\n" +
            "<p>A working installation of the OpenVAS Security Scanner has at least one openvas login registered.\n" +
            "This needs to be done just once. The login and password might not contain spaces or double dots (..).</p>\n" +
            "<p><b>Login of the user</b>: Type the user login name here.</p>\n" +
            "<p><b>Password for user</b>: Type the password for the user here.</p>\n" +
            "<p><b>Password for user (again)</b>: Type the password for the user here, again.</p>\n" +
            "</p>"
        )
      } 

      # EOF
    end
  end
end
