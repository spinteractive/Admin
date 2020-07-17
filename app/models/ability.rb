# frozen_string_literal: true

# BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
#
# Copyright (c) 2018 BigBlueButton Inc. and by respective authors (see below).
#
# This program is free software; you can redistribute it and/or modify it under the
# terms of the GNU Lesser General Public License as published by the Free Software
# Foundation; either version 3.0 of the License, or (at your option) any later
# version.
#
# BigBlueButton is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License along
# with BigBlueButton; if not, see <http://www.gnu.org/licenses/>.

class Ability
  include CanCan::Ability

  def initialize(user)
    if !user
      cannot :manage, AdminsController
      cannot :manage, BillingsController
    elsif user.has_role? :super_admin
      can :manage, :all
    else
      highest_role = user.highest_priority_role
      if highest_role.get_permission("can_edit_site_settings")
        can [:server_action, :server_message, :servers,:site_settings, :update_settings, :coloring, :registration_method], :admin
        can :manage, :billing
      end

      if highest_role.get_permission("can_edit_roles")
        can [:server_action, :server_message, :servers, :roles, :new_role, :change_role_order, :update_role, :delete_role], :admin
      end

      if highest_role.get_permission("can_manage_users")
        can [:server_action, :server_message, :servers, :index, :edit_user, :promote, :demote, :ban_user, :unban_user,
             :approve, :invite, :reset, :undelete, :merge_user], :admin
      end

      can [:server_recordings, :server_rooms], :admin if highest_role.get_permission("can_manage_rooms_recordings")

      if user.has_role?('Teacher')
        can [:server_action, :server_message, :servers], :admin
      end

      no_edit_permissions = !highest_role.get_permission("can_edit_site_settings") &&
                            !highest_role.get_permission("can_edit_roles") &&
                            !highest_role.get_permission("can_manage_users") &&
                            !highest_role.get_permission("can_manage_rooms_recordings")

      if no_edit_permissions && !user.has_role?('Teacher')
        cannot :manage, AdminsController
      end

      if no_edit_permissions
        cannot :manage, BillingsController
      end
    end
  end
end
