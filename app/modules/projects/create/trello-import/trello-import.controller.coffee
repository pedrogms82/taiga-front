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
# File: trello-import.controller.coffee
###

class TrelloImportController
    constructor: (@trelloImportService, @confirm, @translate, @projectUrl, @location) ->
        @.project = null
        taiga.defineImmutableProperty @, 'projects', () => return @trelloImportService.projects
        taiga.defineImmutableProperty @, 'members', () => return @trelloImportService.projectUsers

        @.startProjectSelector()

    startProjectSelector: () ->
        @trelloImportService.fetchProjects().then () => @.step = 'project-select-trello'

    onSelectProject: (project) ->
        @.step = 'project-form-trello'
        @.project = project

    onSaveProjectDetails: (project) ->
        @.project = project
        @.step = 'project-members-trello'

        @trelloImportService.fetchUsers(@.project.get('id'))

    startImport: (users) ->
        loader = @confirm.loader(@translate.instant('PROJECT.IMPORT.IN_PROGRESS.TITLE'))

        loader.start()
        loader.update('', @translate.instant('PROJECT.IMPORT.IN_PROGRESS.TITLE'), @translate.instant('PROJECT.IMPORT.IN_PROGRESS.DESCRIPTION'))

        @trelloImportService.importProject(
            @.project.get('id'),
            users,
            @.project.get('keepExternalReference'),
            @.project.get('is_private')
        ).then (project) =>
            loader.stop()
            @location.url(@projectUrl.get(project))

    onSelectUsers: (users) ->
        @.startImport(users)

        return null

angular.module('taigaProjects').controller('TrelloImportCtrl', [
    'tgTrelloImportService',
    '$tgConfirm',
    '$translate',
    '$projectUrl',
    '$location',
    TrelloImportController])
