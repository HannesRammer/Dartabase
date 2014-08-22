part of dartabaseMigration;

final Map serverRoutes={
  
  'projectMapping':{'url':new UrlPattern(r'/projectMapping'),'method':'GET','action': loadProjectMapping },
  'serverStatus':{'url':new UrlPattern(r'/requestServerStatus'),'method':'GET','action': serverStatus },
  'loadConfig':{'url':new UrlPattern(r'/requestConfig'),'method':'GET','action': loadConfig },
  'loadSchema':{'url':new UrlPattern(r'/requestSchema'),'method':'GET','action': loadSchema },
  'loadMigration':{'url':new UrlPattern(r'/requestMigrations'),'method':'GET','action': loadMigrations },
  'initiateMigration':{'url':new UrlPattern(r'/initiateMigration'),'method':'GET','action': initiateDartabase },
  'runMigration':{'url':new UrlPattern(r'/runMigration'),'method':'GET','action': runMigration },
  
  'saveConfig':{'url':new UrlPattern(r'/saveConfig'),'method':'POST','action': saveConfig }
};

final Map clientRoutes={
  
  
};