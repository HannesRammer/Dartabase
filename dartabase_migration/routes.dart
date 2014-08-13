part of dartabaseMigration;

final Map serverRoutes={
  
  'projectMapping':{'url':new UrlPattern(r'/projectMapping'),'method':'GET','action': loadProjectMapping },
  'serverStatus':{'url':new UrlPattern(r'/serverStatus'),'method':'GET','action': serverStatus },
  'loadConfig':{'url':new UrlPattern(r'/config'),'method':'GET','action': loadConfig },
  'loadMigration':{'url':new UrlPattern(r'/migrations'),'method':'GET','action': loadMigrations },
  'initiateMigration':{'url':new UrlPattern(r'/initiateMigration'),'method':'GET','action': initiateDartabase },
  'runMigration':{'url':new UrlPattern(r'/runMigration'),'method':'GET','action': runMigration },
  
  'saveConfig':{'url':new UrlPattern(r'/saveConfig'),'method':'POST','action': saveConfig }
};

final Map clientRoutes={
  
  'projectMapping':{'url':new UrlPattern(r'/projectMapping'),'method':'GET','action': loadProjectMapping },
  'serverStatus':{'url':new UrlPattern(r'/serverStatus'),'method':'GET','action': serverStatus },
  'loadConfig':{'url':new UrlPattern(r'/config'),'method':'GET','action': loadConfig },
  'loadMigration':{'url':new UrlPattern(r'/migrations'),'method':'GET','action': loadMigrations },
  'initiateMigration':{'url':new UrlPattern(r'/initiateMigration'),'method':'GET','action': initiateDartabase },
  'runMigration':{'url':new UrlPattern(r'/runMigration'),'method':'GET','action': runMigration },
  
  'saveConfig':{'url':new UrlPattern(r'/saveConfig'),'method':'POST','action': saveConfig }
};