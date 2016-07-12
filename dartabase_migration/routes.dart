part of dartabaseMigration;

final Map serverRoutes = {

    'projectMapping':{'url':new UrlPattern(r'/projectMapping'), 'method':'GET', 'action': loadProjectMapping},
    'serverStatus':{'url':new UrlPattern(r'/requestServerStatus'), 'method':'GET', 'action': requestServerStatus, 'async':true},
    'loadConfig':{'url':new UrlPattern(r'/requestConfig'), 'method':'GET', 'action': loadConfig},
    'loadSchema':{'url':new UrlPattern(r'/requestSchema'), 'method':'GET', 'action': loadSchema},
    'loadMigration':{'url':new UrlPattern(r'/requestMigrations'), 'method':'GET', 'action': loadMigrations, 'async':true},
    'initiateMigration':{'url':new UrlPattern(r'/initiateMigration'), 'method':'GET', 'action': initiateDartabase, 'async':true},
    'runMigration':{'url':new UrlPattern(r'/runMigration'), 'method':'GET', 'action': runMigration, 'async':true},

    'createMigration':{'url':new UrlPattern(r'/createMigration'), 'method':'POST', 'action': createMigration},
    'generateModels':{'url':new UrlPattern(r'/generateModels'), 'method':'POST', 'action': generateModels, 'async':true},
    'generateSchema':{'url':new UrlPattern(r'/generateSchema'), 'method':'POST', 'action': generateSchemaFromExistingDatabase, 'async':true},
    'generateViews':{'url':new UrlPattern(r'/generateViews'), 'method':'POST', 'action': generateViews},
    'generateServer':{'url':new UrlPattern(r'/generateServer'), 'method':'POST', 'action': generateServer},

    'saveConfig':{'url':new UrlPattern(r'/saveConfig'), 'method':'POST', 'action': saveConfig}
};

final Map clientRoutes = {
};