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
# File: import-project.controller.coffee
###

class ImportProjectController
    @.$inject = [
        'tgTrelloImportService',
        'tgJiraImportService',
        'tgGithubImportService',
        'tgAsanaImportService',
        '$location',
        '$window',
        '$routeParams',
        '$tgNavUrls'
    ]

    constructor: (@trelloService, @jiraService, @githubService, @asanaService, @location, @window, @routeParams, @tgNavUrls) ->

    start: ->
        @.token = null
        @.from = @routeParams.platform

        locationSearch = @location.search()

        jiraOauthToken = locationSearch.oauth_token

        if @.from == "asana"
            @.token = JSON.parse(decodeURIComponent(token))

        if @.from == "asana"
            asanaOauthToken = locationSearch.code

        if @.from  == 'trello'
            if locationSearch.oauth_verifier
                trelloOauthToken = locationSearch.oauth_verifier
                return @trelloService.authorize(trelloOauthToken).then (token) => @location.search({token: token})
            else if locationSearch.token
                @.token = locationSearch.token
                @trelloService.setToken(locationSearch.token)

        if @.from == "github"
            if locationSearch.code
                githubOauthToken = locationSearch.code
                return @githubService.authorize(githubOauthToken).then (token) => @location.search({token: token})
            else if locationSearch.token
                @.token = locationSearch.token
                @githubService.setToken(locationSearch.token)

        if jiraOauthToken
            return @jiraService.authorize().then (data) =>
                @location.search({from: "jira", token: data.token, url: data.url})

        if asanaOauthToken
            return @asanaService.authorize(asanaOauthToken).then (token) =>
                @location.search({from: "asana", token: encodeURIComponent(JSON.stringify(token))})

    select: (from) ->
        if from == "trello"
            @trelloService.getAuthUrl().then (url) =>
                @window.open(url, "_self")
        else if from == "jira"
            @jiraService.getAuthUrl(@.jiraUrl).then (url) =>
                @window.open(url, "_self")
        else if from == "github"
            callbackUri = @location.absUrl() + "/github"
            @githubService.getAuthUrl(callbackUri).then (url) =>
                @window.open(url, "_self")
        else if from == "asana"
            callbackUri = @location.absUrl() + "?from=asana"
            @asanaService.getAuthUrl(callbackUri).then (url) =>
                @window.open(url, "_self")
        else
            @.from = from

    unfoldOptions: (options) ->
        @.unfoldedOptions = options

    cancelCurrentImport: () ->
        @location.url(@tgNavUrls.resolve('create-project-import'))

angular.module("taigaProjects").controller("ImportProjectCtrl", ImportProjectController)
