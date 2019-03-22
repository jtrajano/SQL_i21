	-- this update the right connection properties. 
	-- make sure you either provide the right strUserName and strPassword or have the user change it on Report Manager.
	update tblRMConnection
	set strServerName = @@SERVERNAME, strDatabase = db_name(), strUserName = '', strPassword = '',strPort='',ysnRemote = 0
	where strName in ('i21')
