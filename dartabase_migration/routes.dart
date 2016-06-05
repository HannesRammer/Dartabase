part of dartabaseMigration;

final Map serverRoutes={
  
  'projectMapping':{'url':new UrlPattern(r'/projectMapping'),'method':'GET','action': loadProjectMapping },
  'serverStatus':{'url':new UrlPattern(r'/requestServerStatus'),'method':'GET','action': requestServerStatus ,'async':true},
  'loadConfig':{'url':new UrlPattern(r'/requestConfig'),'method':'GET','action': loadConfig },
  'loadSchema':{'url':new UrlPattern(r'/requestSchema'),'method':'GET','action': loadSchema },
  'loadMigration':{'url':new UrlPattern(r'/requestMigrations'),'method':'GET','action': loadMigrations,'async':true },
  'initiateMigration':{'url':new UrlPattern(r'/initiateMigration'),'method':'GET','action': initiateDartabase,'async':true  },
  'runMigration':{'url':new UrlPattern(r'/runMigration'),'method':'GET','action': runMigration ,'async':true},

  'createMigration':{'url':new UrlPattern(r'/createMigration'),'method':'POST','action': createMigration},

  'saveConfig':{'url':new UrlPattern(r'/saveConfig'),'method':'POST','action': saveConfig }
};

final Map clientRoutes={
  
  
};