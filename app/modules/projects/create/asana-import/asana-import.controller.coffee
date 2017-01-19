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
# File: asana-import.controller.coffee
###

class AsanaImportController
    constructor: (@asanaImportService, @confirm, @translate, @projectUrl, @location) ->
        @.step = 'autorization-asana'
        @.project = null
        taiga.defineImmutableProperty @, 'projects', () => return @asanaImportService.projects
        taiga.defineImmutableProperty @, 'members', () => return @asanaImportService.projectUsers

         #@.step = 'project-members-asana'
        @.startProjectSelector()

    startProjectSelector: () ->
        @.step = 'project-select-asana'
        @asanaImportService.fetchProjects()

    onSelectProject: (project) ->
        @.step = 'project-form-asana'
        @.project = project

    onSaveProjectDetails: (project) ->
        @.project = project
        @.step = 'project-members-asana'

        @asanaImportService.fetchUsers(@.project.get('id'))

    startImport: (users) ->
        loader = @confirm.loader(@translate.instant('PROJECT.IMPORT.IN_PROGRESS.TITLE'))

        loader.start()
        loader.update('', @translate.instant('PROJECT.IMPORT.IN_PROGRESS.TITLE'), @translate.instant('PROJECT.IMPORT.IN_PROGRESS.DESCRIPTION'))

        @asanaImportService.importProject(
            @.project.get('id'),
            users,
            @.project.get('keepExternalReference'),
            @.project.get('is_private')
            @.project.get('project_type')
        ).then (project) =>
            loader.stop()
            @location.url(@projectUrl.get(project))

    onSelectUsers: (users) ->
        @.startImport(users)
        return null

angular.module('taigaProjects').controller('AsanaImportCtrl', [
    'tgAsanaImportService',
    '$tgConfirm',
    '$translate',
    '$projectUrl',
    '$location',
    AsanaImportController])
