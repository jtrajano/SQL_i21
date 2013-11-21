/*
	BEGIN CONVERSION Report Connections
*/

	-- this update the right connection properties. 
	-- make sure you either provide the right strUserName and strPassword or have the user change it on Report Manager.
	update tblRMConnections
	set strServerName = @@SERVERNAME, strDatabase = db_name(), strUserName = '', strPassword = ''
	where strName in ('Tank Management', 'General Ledger', 'i21')

/*
	BEGIN CONVERSION Report Connections
*/