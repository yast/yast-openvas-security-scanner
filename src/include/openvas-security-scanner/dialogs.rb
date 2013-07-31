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

# File:	include/openvas-security-scanner/dialogs.ycp
# Package:	Configuration of openvas-security-scanner
# Summary:	Dialogs definitions
# Authors:	Felix Wolfsteller <felix.wolfsteller@intevation.de>
#
# $**Id$
module Yast
  module OpenvasSecurityScannerDialogsInclude
    def initialize_openvas_security_scanner_dialogs(include_target)
      Yast.import "UI"

      textdomain "openvas-security-scanner"

      Yast.import "Label"
      Yast.import "Wizard"
      Yast.import "OpenvasSecurityScanner"
      Yast.import "Popup"

      Yast.include include_target, "openvas-security-scanner/helps.rb"
    end

    # OpenVAS Scan-Server Configuration Dialog
    #
    # @return [Object] dialog result
    def ScannerConfigurationDialog
      caption = _("OpenVAS Security Scanner Configuration")

      no_feed_selected = OpenvasSecurityScanner.feed_choice == nil ||
        OpenvasSecurityScanner.feed_choice == "No Feed" ||
        OpenvasSecurityScanner.feed_choice == ""

      radio_group = VBox()
      radio_group = Builtins.add(
        radio_group,
        Left(
          RadioButton(
            Id(:no_feed),
            Opt(:notify),
            _("&Disable OpenVAS Security Scanner"),
            no_feed_selected
          )
        )
      )

      radio_group = Builtins.add(
        radio_group,
        Left(
          RadioButton(
            Id(:onf),
            Opt(:notify),
            _("Enable and use &OpenVAS NVT Feed"),
            OpenvasSecurityScanner.feed_choice == "OpenVAS NVT Feed"
          )
        )
      )

      # Disable the Greenbone Security Feed option if the GSF scripts are not installed / activated
      if OpenvasSecurityScanner.IsGSFInstalled
        radio_group = Builtins.add(
          radio_group,
          Left(
            RadioButton(
              Id(:gsf),
              Opt(:notify),
              _("Enable and use &Greenbone Security Feed"),
              OpenvasSecurityScanner.feed_choice == "Greenbone Security Feed"
            )
          )
        )
      else
        radio_group = Builtins.add(
          radio_group,
          Left(
            RadioButton(
              Id(:gsf),
              Opt(:disabled),
              _("Enable and use &Greenbone Security Feed"),
              false
            )
          )
        )
      end

      radio_box = RadioButtonGroup(Id(:feed), HVSquash(radio_group))

      gsf_box = VBox()
      if OpenvasSecurityScanner.IsGSFInstalled
        gsf_box = Builtins.add(
          gsf_box,
          PushButton(
            Id(:activate_gsf),
            Opt(:notify, :disabled),
            _("&Activate Greenbone Security Feed Subscription")
          )
        )
        gsf_box = Builtins.add(
          gsf_box,
          PushButton(
            Id(:deactivate_gsf),
            Opt(:notify),
            _("D&eactivate Greenbone Security Feed Subscription")
          )
        )
      else
        gsf_box = Builtins.add(
          gsf_box,
          PushButton(
            Id(:activate_gsf),
            Opt(:notify),
            _("&Activate Greenbone Security Feed Subscription")
          )
        )
        gsf_box = Builtins.add(
          gsf_box,
          PushButton(
            Id(:deactivate_gsf),
            Opt(:notify, :disabled),
            _("D&eactivate Greenbone Security Feed Subscription")
          )
        )
      end

      # Disable the "Sync Now" button if no feed is selected / the OpenVAS service is disabled.
      feed_management_box = VBox()
      sync_now_button = no_feed_selected ?
        PushButton(
          Id(:feedsync_now),
          Opt(:disabled),
          _("&Synchronize with Feed now")
        ) :
        PushButton(
          Id(:feedsync_now),
          Opt(:notify),
          _("&Synchronize with Feed now")
        )
      feed_management_box = Builtins.add(feed_management_box, sync_now_button)

      croncheckbox = CheckBox(
        Id(:cronjob),
        _("Do a da&ily feed synchronization"),
        OpenvasSecurityScanner.daily_sync
      )

      feed_management_box = Builtins.add(feed_management_box, croncheckbox)


      w = 38
      contents = VBox(
        Frame("Security Scanner Service", MinSize(w, 0, radio_box)),
        VSpacing(1),
        Frame("Professional Feed Subscriptions", MinSize(w, 0, gsf_box)),
        VSpacing(1),
        Frame("Feed Management", MinSize(w, 0, feed_management_box)),
        VSpacing(1)
      )

      Wizard.SetContentsButtons(
        caption,
        contents,
        Ops.get_string(@HELPS, "configuration", ""),
        Label.BackButton,
        Label.FinishButton
      )
      Wizard.DisableBackButton

      # Does not make sense to have synchronize with "no feed", disable widgets in that case
      if no_feed_selected
        UI.ChangeWidget(Id(:cronjob), :Enabled, false)
        UI.ChangeWidget(Id(:cronjob), :Value, false)
      end

      ret = nil
      while true
        ret = UI.UserInput

        # handle no feed, onf, gsf and en/disable the daily sync checkbox accordingly.
        if ret == :no_feed
          UI.ChangeWidget(Id(:cronjob), :Enabled, false)
          UI.ChangeWidget(Id(:cronjob), :Value, false)
          UI.ChangeWidget(Id(:feedsync_now), :Enabled, false)
          next
        elsif ret == :onf || ret == :gsf
          UI.ChangeWidget(Id(:cronjob), :Enabled, true)
          UI.ChangeWidget(Id(:feedsync_now), :Enabled, false)
          next
        end


        # Abort?
        if ret == :abort
          if OpenvasSecurityScanner.Abort
            break
          else
            next
          end
        # Next
        elsif ret == :next
          ret = UI.QueryWidget(Id(:feed), :CurrentButton)
          choice = ""
          if ret == :no_feed
            choice = "No Feed"
          elsif ret == :onf
            choice = "OpenVAS NVT Feed"
          elsif ret == :gsf
            choice = "Greenbone Security Feed"
          end

          # Check whether the feed-choice changed, do nothing if so
          if OpenvasSecurityScanner.feed_choice == choice
            ret = :write
          else
            OpenvasSecurityScanner.feed_choice = choice
            if choice == "No Feed"
              ret = :no_feed
            else
              ret = :fetch_new
            end
          end

          ui_dailysync = UI.QueryWidget(Id(:cronjob), :Value)

          if !Convert.to_boolean(ui_dailysync) || choice == "No Feed"
            SCR.Execute(
              path(".target.remove"),
              "/etc/cron.daily/openvas-nvt-sync"
            )
            SCR.Execute(
              path(".target.remove"),
              "/etc/cron.daily/greenbone-nvt-sync"
            )
            OpenvasSecurityScanner.daily_sync = false # Daily sync was checked
          else
            if choice == "OpenVAS NVT Feed"
              SCR.Execute(
                path(".target.symlink"),
                "/usr/sbin/openvas-nvt-sync",
                "/etc/cron.daily/openvas-nvt-sync"
              )
              SCR.Execute(
                path(".target.remove"),
                "/etc/cron.daily/greenbone-nvt-sync"
              )
            elsif choice == "Greenbone Security Feed"
              SCR.Execute(
                path(".target.symlink"),
                "/usr/sbin/greenbone-nvt-sync",
                "/etc/cron.daily/greenbone-nvt-sync"
              )
              SCR.Execute(
                path(".target.remove"),
                "/etc/cron.daily/openvas-nvt-sync"
              )
            end
            OpenvasSecurityScanner.daily_sync = true
          end

          break
        # Do a feed sync
        elsif ret == :feedsync_now
          break
        # Activate GSF
        elsif ret == :activate_gsf
          break
        # Deactivate GSF
        elsif ret == :deactivate_gsf
          OpenvasSecurityScanner.feed_choice = "No Feed"
          break
        else
          Builtins.y2error("unexpected retcode: %1", ret)
          next
        end
      end

      Wizard.RestoreBackButton

      deep_copy(ret)
    end

    # Dialog to enter the location of the Greenbone Security Feed (key) files and scripts
    #
    # @return [Object] dialog result
    def EnterGSFLocationDialog
      caption = _("Greenbone Security Feed Activation")


      contents = VBox(
        PushButton(Id(:gsf_fromfile), Opt(:notify), _("&Import from file")),
        MultiLineEdit(
          Id(:keytext),
          _("Greenbone Access Key (can be base64 encoded)"),
          ""
        )
      )

      Wizard.SetContentsButtons(
        caption,
        contents,
        Ops.get_string(@HELPS, "activategsf", ""),
        Label.BackButton,
        Label.NextButton
      )
      Wizard.DisableBackButton

      ret = nil
      while true
        ret = UI.UserInput
        if ret == :abort
          break
        elsif ret == :gsf_fromfile
          ret_path = UI.AskForExistingFile(
            "/home/",
            "",
            "Choose the Greenbone Access Key File"
          )
          next if ret_path == nil || ret_path == ""
          text = SCR.Read(path(".target.string"), ret_path)
          UI.ChangeWidget(Id(:keytext), :Value, text)
        elsif ret == :next
          text = Convert.to_string(UI.QueryWidget(Id(:keytext), :Value))
          if Builtins.issubstring(text, "-----BEGIN RSA PRIVATE KEY-----")
            #  Assuming its not base64 encoded
            SCR.Write(
              path(".target.string"),
              "/etc/openvas/gsf-access-key",
              text
            )
          else
            #  Assuming it is base64 encoded
            SCR.Write(
              path(".target.string"),
              "/etc/openvas/gsf-access-key.b64",
              text
            )
            SCR.Execute(
              path(".target.bash"),
              "base64 -d /etc/openvas/gsf-access-key.b64 > /etc/openvas/gsf-access-key"
            )
            SCR.Execute(
              path(".target.bash"),
              "rm /etc/openvas/gsf-access-key.b64"
            )
          end
          break
        else
          Builtins.y2error("unexpected retcode: %1", ret)
          next
        end
      end

      Wizard.RestoreBackButton
      deep_copy(ret)
    end

    # Dialog showing progress of disabling the OpenVAS Security Scanner Service.
    #
    # @return [Object] dialog result
    def DisableOpenVASDialog
      Wizard.RestoreHelp(Ops.get_string(@HELPS, "disableopenvas", ""))
      ret = OpenvasSecurityScanner.DisableOpenVAS
      ret ? :next : :abort
    end

    # Dialog showing progress of deactivating the Greenbone Security Feed.
    #
    # @return [Object] dialog result
    def DeactivateGSFDialog
      Wizard.RestoreHelp(Ops.get_string(@HELPS, "deactivategsf", ""))
      ret = OpenvasSecurityScanner.DeactivateGSF
      ret ? :next : :abort
    end


    # Dialog to create an (openvas) user.
    #
    # @return Yet unused next or abort.
    def AddUserDialog
      caption = _("Add User to OpenVAS Security Scanner")
      message = _(
        "In order for the OpenVAS Security Scanner to work,\na openvas login has to be registered.\n"
      )

      contents = VBox(
        Label(message),
        InputField(Id(:user_login), _("&Login of the user"), "")
      )
      contents = Builtins.add(
        contents,
        Password(Id(:user_pass), _("&Password for user"), "")
      )
      contents = Builtins.add(
        contents,
        Password(Id(:user_pass_again), _("P&assword for user (again)"), "")
      )

      Wizard.SetContentsButtons(
        caption,
        contents,
        Ops.get_string(@HELPS, "adduser", ""),
        Label.BackButton,
        Label.NextButton
      )
      Wizard.DisableBackButton

      ret = nil

      while true
        ret = UI.UserInput
        if ret == :abort
          break
        elsif ret == :next
          login = UI.QueryWidget(Id(:user_login), :Value)
          pw1 = UI.QueryWidget(Id(:user_pass), :Value)
          pw2 = UI.QueryWidget(Id(:user_pass_again), :Value)
          # Do some input checks
          if login == nil || login == ""
            Popup.Message(_("Login name must not be empty."))
            next
          elsif Builtins.issubstring(Convert.to_string(login), " ") ||
              Builtins.issubstring(Convert.to_string(pw1), " ") ||
              Builtins.issubstring(Convert.to_string(pw2), " ") ||
              Builtins.issubstring(Convert.to_string(login), "..")
            Popup.Message(
              _(
                "Login name and password must not contain space character or double dots."
              )
            )
            next
          end
          if pw1 == pw2
            addUserCmd = Ops.add(
              Ops.add(
                Ops.add(
                  Ops.add(
                    Ops.add(
                      Ops.add("printf \"", Convert.to_string(login)),
                      "\n\n"
                    ),
                    Convert.to_string(pw1)
                  ),
                  "\n"
                ),
                Convert.to_string(pw2)
              ),
              "\n\n\" | openvas-adduser"
            )

            ret2 = Convert.to_integer(
              SCR.Execute(path(".target.bash"), addUserCmd)
            )
            if ret2 != 0
              Popup.Message(
                _(
                  "Error creating user, try to create it yourself with openvas-adduser and inspect messages."
                )
              )
            end

            Wizard.RestoreBackButton
            return :next
          else
            Popup.Message(_("Must enter equal passwords"))
            next
          end
          break
        else
          Builtins.y2error("unexpected return code: %1", ret)
          next
        end
      end

      Wizard.RestoreBackButton
      deep_copy(ret)
    end
  end
end
