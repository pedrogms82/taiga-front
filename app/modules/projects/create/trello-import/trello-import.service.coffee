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
# File: trello-import.service.coffee
###

class TrelloImportService extends taiga.Service
    @.$inject = [
        'tgResources'
    ]

    constructor: (@resources) ->
        @.projects = Immutable.List()
        @.projectUsers = Immutable.List()

    setToken: (token) ->
        @.token = token

    fetchProjects: () ->
        @resources.trelloImporter.listProjects(@.token).then (projects) => @.projects = projects

    fetchUsers: (projectId) ->
        @resources.trelloImporter.listUsers(@.token, projectId).then (users) => @.projectUsers = users

    importProject: (projectId, userBindings, keepExternalReference, isPrivate) ->
        return new Promise (resolve) =>
            @resources.trelloImporter.importProject(@.token, projectId, userBindings, keepExternalReference, isPrivate).then (response) =>
                @.importedProject = Immutable.fromJS(response.data)
                resolve(@.importedProject)

    getAuthUrl: () ->
        return new Promise (resolve) =>
            @resources.trelloImporter.getAuthUrl().then (response) =>
                @.authUrl = response.data.url
                resolve(@.authUrl)

    authorize: (verifyCode) ->
        return new Promise (resolve) =>
            @resources.trelloImporter.authorize(verifyCode).then (response) =>
                @.token = response.data.token
                resolve(@.token)

angular.module("taigaProjects").service("tgTrelloImportService", TrelloImportService)
