CREATE VIEW [dbo].[vyuHDModule]
	AS
		select
			intModuleId = intModuleId
			,intSMModuleId = intSMModuleId
			,intSort = intSort
			,intTicketGroupId = intTicketGroupId
			,intTicketProductId = intTicketProductId
			,strSMModuleName = (select top 1 strModule from tblSMModule where intModuleId = intSMModuleId)
			,strSMModuleApplicationName = (select top 1 strApplicationName from tblSMModule where intModuleId = intSMModuleId)
			,strSMModuleAppCode = (select top 1 strAppCode from tblSMModule where intModuleId = intSMModuleId)
			,strDescription = strDescription
			,strGroup = (select top 1 strGroup from tblHDTicketGroup where intTicketGroupId = tblHDModule.intTicketGroupId)
			,strModule = strModule
			,ysnSupported = ysnSupported
			,strProduct = (select top 1 strProduct from tblHDTicketProduct where intTicketProductId = tblHDModule.intTicketProductId)
			,strJIRAProject
		from
			tblHDModule
