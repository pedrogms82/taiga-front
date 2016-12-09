###
# Copyright (C) 2014-2016 Taiga Agile LLC <taiga@taiga.io>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# File: create-project-form.controller.coffee
###

class CreatetProjectFormController
    @.$inject = [
        "tgCurrentUserService",
        "tgProjectsService",
        "$projectUrl",
        "$location"
   ]

    constructor: (@currentUserService, @projectsService, @projectUrl, @location) ->
        @.projectForm = {
            is_private: false
        }

        @.canCreatePublicProjects = @currentUserService.canCreatePublicProjects()
        @.canCreatePrivateProjects = @currentUserService.canCreatePrivateProjects()

        if @.type == 'scrum'
            @.projectForm.creation_template = 1
        else
            @.projectForm.creation_template = 2

    submit: () ->
        @.submiting = true

        @projectsService.create(@.projectForm).then (project) =>
            @location.url(@projectUrl.get(project))

angular.module('taigaProjects').controller('CreateProjectFormCtrl', CreatetProjectFormController)
