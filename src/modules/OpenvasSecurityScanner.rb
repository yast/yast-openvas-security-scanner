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

# File:	modules/OpenvasSecurityScanner.ycp
# Package:	Configuration of openvas-security-scanner
# Summary:	OpenvasSecurityScanner settings, input and output functions
# Authors:	Felix Wolfsteller <felix.wolfsteller@intevation.de>
#
# $**Id$
#
# Representation of the configuration of openvas-security-scanner.
# Input and output routines.
require "yast"

module Yast
  class OpenvasSecurityScannerClass < Module
    def main
      Yast.import "UI"
      textdomain "openvas-security-scanner"

      Yast.import "FileUtils"
      Yast.import "Message"
      Yast.import "Popup"
      Yast.import "Progress"
      Yast.import "Report"
      Yast.import "Service"
      Yast.import "Summary"


      # Write only, used during autoinstallation.
      # Don't run services and SuSEconfig, it's all done at one place.
      @write_only = false

      # The users choosen feed. Currently one of "No Feed",
      # "Greenbone Security Feed" or "OpenVAS NVT Feed".
      @feed_choice = ""

      # Whether or not the user choose to daily synchronize with feed via a cron job.
      @daily_sync = false


      # Sleeping time beetwing progress steps.
      @sl = 20
    end

    # Returns whether the /usr/sbin/greenbone-nvt-sync and
    # /etc/openvas/gsf-access-key exist.
    # @return true if /usr/sbin/greenbone-nvt-sync and /etc/openvas/gsf-access-key
    #         exist.
    def IsGSFInstalled
      if FileUtils.Exists("/usr/sbin/greenbone-nvt-sync") &&
          FileUtils.Exists("/etc/openvas/gsf-access-key")
        return true
      end

      false
    end

    # Ask if user really wants to abort
    # @return true on user intended abort.
    def Abort
      Popup.ReallyAbort(true)
    end

    # Checks whether an Abort button has been pressed.
    # If so, calls function to confirm the abort call.
    #
    # @return true if abort confirmed
    def PollAbort
      return Abort() if UI.PollInput == :abort

      false
    end

    # Removes contents of /var/cache/openvas .
    # @return true.
    def CleanCache
      SCR.Execute(
        path(".target.bash"),
        "for i in /var/cache/openvas/*; do rm -rf $i; done"
      )
      true
    end

    # Removes contents of /usr/lib/openvas/plugins .
    # @return true.
    def CleanNVTDir
      SCR.Execute(
        path(".target.bash"),
        "for i in /usr/lib/openvas/plugins/*; do rm -rf $i; done"
      )
      true
    end


    # Checks /var/lib/openvas/users/ for content. If content is found this means a user
    # for openvas exists.
    # @return true if users were found, false otherwise.
    def CheckUserExists
      users = Convert.convert(
        SCR.Read(path(".target.dir"), "/var/lib/openvas/users/"),
        :from => "any",
        :to   => "list <string>"
      )
      if Ops.greater_than(Builtins.size(users), 0)
        return true
      else
        return false
      end
    end


    # Read all OpenVAS Security Scanner settings
    # @return true on success
    def Read
      # OpenvasSecurityScanner read dialog caption
      caption = _("Initializing OpenVAS Security Scanner Configuration")

      steps = 2

      Progress.New(
        caption,
        " ",
        steps,
        [
          # Progress stage 1/2
          _("Read current OpenVAS Security Scanner configuration"),
          # Progress stage 2/2
          _("Read current openvas-scanner state")
        ],
        [
          # Progress stage 1/2
          _("Reading current OpenVAS Security Scanner configuration..."),
          # Progress stage 2/2
          _("Reading current openvas-scanner state..."),
          # Progress finished
          Message.Finished
        ],
        ""
      )

      Builtins.sleep(@sl)

      return false if PollAbort()
      Progress.NextStage
      Report.Error(Message.CannotReadCurrentSettings) if false
      Builtins.sleep(@sl)

      return false if PollAbort()
      Progress.NextStep
      Report.Error(_("Cannot read current openvas-scanner state.")) if false
      Builtins.sleep(@sl)

      return false if PollAbort()
      Progress.NextStage
      Builtins.sleep(@sl)

      @feed_choice = SCR.Read(path(".etc.sysconfig.openvas-scanner.feed"))
      @feed_choice = "No Feed" if @feed_choice == nil

      @daily_sync = SCR.Read(path(".etc.sysconfig.openvas-scanner.daily_sync")) == "yes"

      true
    end


    # Write all OpenVAS Security Scanner settings.
    # @return true on success
    def Write
      # Openvas Security Scanner write dialog caption
      caption = _("Saving OpenVAS Security Scanner Configuration")

      steps = 2

      Progress.New(
        caption,
        " ",
        steps,
        [
          # Progress stage 1/2
          _("Write the OpenVAS Security Scanner settings")
        ],
        [
          # Progress step 1/2
          _("Writing the OpenVAS Security Scanner settings..."),
          Message.Finished
        ],
        ""
      )

      Builtins.sleep(@sl)

      # Write settings to conf file
      return false if PollAbort()
      Progress.NextStage
      # Error message
      if !SCR.Write(path(".etc.sysconfig.openvas-scanner.feed"), @feed_choice) ||
          !SCR.Write(
            path(".etc.sysconfig.openvas-scanner.daily_sync"),
            @daily_sync ? "yes" : "no"
          ) ||
          !SCR.Write(path(".etc.sysconfig.openvas-scanner"), nil)
        SCR.Write(path(".etc.sysconfig.openvas-scanner"), nil)
        Report.Error(_("Cannot write OpenVAS Security Scanner settings."))
      end

      Builtins.sleep(@sl)

      Progress.NextStage

      true
    end


    # Disable the openvas service and clean up the cache and plugins directory.
    # @return true on success
    def DisableOpenVAS
      caption = _("Disable the OpenVAS Security Scanner")
      steps = 3

      Progress.New(
        caption,
        " ",
        steps,
        [
          # Progress stage 1/3
          _("Stopp the OpenVAS Security Scanner service"),
          # Progress stage 2/3
          _("Disable the OpenVAS Security Scanner service"),
          # Progress stage 3/3
          _("Delete the NVT datastores")
        ],
        [
          # Progress stage 1/3
          _("Stopping the OpenVAS Security Scanner service..."),
          # Progress stage 2/3
          _("Disabling the OpenVAS Security Scanner service..."),
          # Progress stage 3/3
          _("Deleting the NVT datastores..."),
          Message.Finished
        ],
        ""
      )

      # Stop the service (if running)
      return false if PollAbort()
      Progress.NextStage
      Service.Stop("openvas-scanner")
      Builtins.sleep(@sl)

      # Disable the service
      return false if PollAbort()
      Progress.NextStage
      Service.Adjust("openvas-scanner", "disable")
      Builtins.sleep(@sl)

      # Clean NVT Cache and Collection
      return false if PollAbort()
      Progress.NextStage
      CleanCache()
      CleanNVTDir()
      Builtins.sleep(@sl)

      Progress.NextStage
      Builtins.sleep(@sl)

      true
    end

    # Fetches a NVT Feed.
    # @return true on success
    def FetchFeed
      caption = _("Fetching NVT Feed")

      steps = 4

      Progress.New(
        caption,
        " ",
        steps,
        [
          # Progress stage 1/4
          _("Stop the OpenVAS Security Scanner service"),
          # Progress stage 2/4
          _("Delete the NVT datastores (may take a while)"),
          # Progress stage 3/4
          _("Fetch the Feed (may take a while)"),
          # Progress stage 4/4
          _("Start the OpenVAS Security Scanner service (may take a while)")
        ],
        [
          # Progress stage 1/4
          _("Stopping the OpenVAS Security Scanner service..."),
          # Progress stage 2/4
          _("Deleting the NVT datastores  (may take a while)..."),
          # Progress stage 3/4
          _("Fetching the Feed (may take a while)..."),
          # Progress stage 4/4
          _(
            "Starting the OpenVAS Security Scanner service (may take a while)..."
          ),
          Message.Finished
        ],
        ""
      )

      Builtins.sleep(@sl)

      # Stop openvas service
      return false if PollAbort()
      Progress.NextStage
      Service.Stop("openvas-scanner")
      Builtins.sleep(@sl)

      # Clean the NVT Cache and Collection
      return false if PollAbort()
      Progress.NextStage
      CleanCache()
      CleanNVTDir()
      Builtins.sleep(@sl)

      # Sync with feed
      return false if PollAbort()
      Progress.NextStage
      if @feed_choice == "Greenbone Security Feed"
        SCR.Execute(path(".target.bash"), "greenbone-nvt-sync")
      else
        SCR.Execute(path(".target.bash"), "openvas-nvt-sync")
      end
      # @todo Once the feed synchronization scripts have been consolidated, it
      #       will be possible to check the return.
      Builtins.sleep(@sl)

      # Start openvas service
      return false if PollAbort()
      Progress.NextStage
      Service.Adjust("openvas-scanner", "enable")
      if !Service.Start("openvas-scanner")
        Report.Error(_("Could not start OpenVAS Security Scanner service."))
      end
      # Report::Error (Message::CannotAdjustService ("openvas-scanner"));
      # might be more accurate
      Builtins.sleep(@sl)

      Progress.NextStage
      Builtins.sleep(@sl)

      true
    end

    # Fetches a NVT Feed.
    # @return true on success
    def SyncWithFeed
      caption = _("Synchronization with NVT Feed")

      steps = 3

      Progress.New(
        caption,
        " ",
        steps,
        [
          # Progress stage 1/3
          _("Stop the OpenVAS Security Scanner service"),
          # Progress stage 2/3
          _("Fetch the Feed (may take a while)"),
          # Progress stage 2/3
          _("Start the OpenVAS Security Scanner service (may take a while)")
        ],
        [
          # Progress stage 1/3
          _("Stopping the OpenVAS Security Scanner service..."),
          # Progress stage 2/3
          _("Fetching the Feed (may take a while)..."),
          # Progress stage 3/3
          _(
            "Starting the OpenVAS Security Scanner service (may take a while)..."
          ),
          Message.Finished
        ],
        ""
      )

      Builtins.sleep(@sl)

      # Stop openvas service
      return false if PollAbort()
      Progress.NextStage
      Service.Stop("openvas-scanner")
      Builtins.sleep(@sl)

      # Sync with feed
      return false if PollAbort()
      Progress.NextStage
      if @feed_choice == "Greenbone Security Feed"
        SCR.Execute(path(".target.bash"), "greenbone-nvt-sync")
      else
        SCR.Execute(path(".target.bash"), "openvas-nvt-sync")
      end
      # @todo Once the feed synchronization scripts have been consolidated, it
      #       will be possible to check the return.
      Builtins.sleep(@sl)

      # Start openvas service
      return false if PollAbort()
      Progress.NextStage
      Service.Adjust("openvas-scanner", "enable")
      if !Service.Start("openvas-scanner")
        Report.Error(_("Could not start OpenVAS Security Scanner service."))
      end
      # Report::Error (Message::CannotAdjustService ("openvas-scanner"));
      # might be more accurate
      Builtins.sleep(@sl)

      Progress.NextStage
      Builtins.sleep(@sl)

      true
    end

    # Deactivate the GSF.
    #
    # @return TRUE is not aborted, false otherwise.
    def DeactivateGSF
      # Deactivate Greenbone Security Feed dialog caption
      caption = _("Deactivate the Greenbone Security Feed Subscription")

      steps = 2

      Progress.New(
        caption,
        " ",
        steps,
        [
          # Progress stage 1/2
          _("Remove Greenbone Security Feed Access Key"),
          # Progress stage 1/2
          _("Delete NVT datastores")
        ],
        [
          # Progress stage 1/2
          _("Removing Greenbone Security Feed Access Key..."),
          # Progress stage 2/2
          _("Deleting NVT datastores..."),
          Message.Finished
        ],
        ""
      )

      Builtins.sleep(@sl)

      # Removing Access Key
      return false if PollAbort()
      Progress.NextStage
      SCR.Execute(path(".target.bash"), "rm -rf /etc/openvas/gsf-access-key")
      #sleep (sl);

      # Clean the NVT Cache and Collection
      return false if PollAbort()
      Progress.NextStage
      CleanCache()
      CleanNVTDir()
      Builtins.sleep(@sl)

      true
    end

    # Import the Access Key, delete the file.
    # @return true if greenbone access key import succeeded.
    def ImportGreenboneKey
      # Ensure /etc/openvas/gnupg exists
      SCR.Execute(path(".target.bash"), "mkdir -p /etc/openvas/gnupg")
      SCR.Execute(path(".target.bash"), "chmod 770 /etc/openvas/gnupg")

      # Import key
      SCR.Execute(path(".target.bash"), "chmod 400 /etc/openvas/gsf-access-key")
      cmd = "gpg --homedir=/etc/openvas/gnupg --status-file /var/log/openvas/gbkeyimport.state --logger-file /var/log/openvas/gbkeyimport.log --import /etc/openvas/gsf-access-key"
      ret = Convert.to_integer(SCR.Execute(path(".target.bash"), cmd))
      if ret != 0
        Report.Error(_("The Greenbone Access Key could not be imported."))
        return false
      end
      # Set trust in the Greenbone Security Feed Signing Key
      ret = Convert.to_integer(
        SCR.Execute(
          path(".target.bash"),
          "echo `grep IMPORT_OK /var/log/openvas/gbkeyimport.state | cut -d \" \" -f 4`:6: | gpg --homedir=/etc/openvas/gnupg --status-file /var/log/openvas/gbkeytrust.state --logger-file /var/log/openvas/gbkeytrust.log --import-ownertrust"
        )
      )
      if ret != 0
        Report.Error(
          _("Trust-level for the Greenbone Access Key could not be set.")
        )
        return false
      end

      # Remove the log and state files
      SCR.Execute(
        path(".target.bash"),
        "rm -f /var/log/openvas/gbkeyimport.state /var/log/openvas/gbkeyimport.log /var/log/openvas/gbkeytrust.state /var/log/openvas/gbkeytrust.log"
      )

      # Check whether signature checks are enabled
      result = Convert.to_map(
        SCR.Execute(
          path(".target.bash_output"),
          "openvassd -s | grep nasl_no_signature_check | sed 's/nasl_no_signature_check *= *//'"
        )
      )
      if Ops.get_string(result, "stdout", "") != "no\n"
        Builtins.y2milestone(
          "stdout: _%1_",
          Ops.get_string(result, "stdout", "")
        )
        Popup.Warning(
          _(
            "You seem to have disabled signature checking in your OpenVAS configuration.\n" +
              "\n" +
              "Please make sure that the line\n" +
              "    nasl_no_signature_check = no\n" +
              "occurs in the file /etc/openvas/openvassd.conf."
          )
        )
      end

      true
    end

    # Fetches a NVT Feed.
    # @return true on success
    def ActivateGSF
      # Openvas Security Scanner Feed Fetching dialog caption
      caption = _("Activate the Greenbone Security Feed Subscription")

      steps = 3

      Progress.New(
        caption,
        " ",
        steps,
        [
          # Progress stage 1/3
          _("Add feed.greenbone.net to list of known hosts"),
          # Progress stage 2/3
          _("Import Greenbone Key"),
          # Progress stage 3/3
          _("Test Key")
        ],
        [
          # Progress stage 1/3
          _("Adding feed.greenbone.net to list of known hosts"),
          # Progress stage 2/3
          _("Importing Greenbone Key..."),
          # Progress stage 3/3
          _("Testing Key..."),
          Message.Finished
        ],
        ""
      )

      Builtins.sleep(@sl)

      # Adding greenbone feed location to list of known hosts
      return false if PollAbort()
      Progress.NextStage
      SCR.Execute(path(".target.bash"), "mkdir -p /root/.ssh/")
      SCR.Execute(path(".target.bash"), "touch /root/.ssh/known_hosts")
      SCR.Execute(
        path(".target.bash"),
        "echo \"[feed.greenbone.net]:24,[193.108.181.139]:24 ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAmVIt4lOPi1lVJfFCtiNjGR4kHj377C6jMY4iaxotYueuGq8l8B1YIMUMLQzaUeaPwOGMZl5mWUT158zaiWK4zOzZarFLey6JrKfrnDZMdCcCneZPBRbMJUxiV1jv4U+/Vp/V1wO6OJ+S9XkodxvN9+vjAhcXspKXcRol30+T9mgilWK+nvSTVEhce+JJYz+gdQFN+1xgkPhjGbXSjHT7zB5fVjWe7TYLGhdqj1U+NTVOcKNn0wMBRGM3T63rKV71KI1hmLdX6+VmVQOCjYpqsFRh0TZadh5cEE5gmPDCnGlXCA9BrilOMSRvsTySs30xN4/Z5RHPWbDS0rwvqBf9Lw==\" >> /root/.ssh/known_hosts"
      )
      Builtins.sleep(@sl)

      # Import the Greenbone Access Key
      bret = ImportGreenboneKey()
      if bret == false
        Report.Error(_("The greenbone key could not be imported."))
      end
      Builtins.sleep(@sl)


      # Do a self test
      return false if PollAbort()
      Progress.NextStage
      ret = Convert.to_integer(
        SCR.Execute(path(".target.bash"), "greenbone-nvt-sync --selftest")
      )
      Report.Error(_("The synchronization test failed.")) if ret != 0
      Builtins.sleep(@sl)

      Progress.NextStage
      Builtins.sleep(@sl)

      true
    end

    publish :variable => :feed_choice, :type => "any"
    publish :variable => :daily_sync, :type => "boolean"
    publish :function => :IsGSFInstalled, :type => "boolean ()"
    publish :function => :Abort, :type => "boolean ()"
    publish :function => :PollAbort, :type => "boolean ()"
    publish :function => :CheckUserExists, :type => "boolean ()"
    publish :function => :Read, :type => "boolean ()"
    publish :function => :Write, :type => "boolean ()"
    publish :function => :DisableOpenVAS, :type => "boolean ()"
    publish :function => :FetchFeed, :type => "boolean ()"
    publish :function => :SyncWithFeed, :type => "boolean ()"
    publish :function => :DeactivateGSF, :type => "boolean ()"
    publish :function => :ImportGreenboneKey, :type => "boolean ()"
    publish :function => :ActivateGSF, :type => "boolean ()"
  end

  OpenvasSecurityScanner = OpenvasSecurityScannerClass.new
  OpenvasSecurityScanner.main
end
