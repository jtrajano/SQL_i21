CREATE VIEW [dbo].[vyuHDGroupSearch]
	AS
	select
		tblHDTicketGroup.*
		,strEscalation = (select tblEMEntity.strName from tblEMEntity where tblEMEntity.intEntityId = (select top 1 tblHDGroupUserConfig.intUserSecurityEntityId from tblHDGroupUserConfig where tblHDGroupUserConfig.intTicketGroupId = tblHDTicketGroup.intTicketGroupId and tblHDGroupUserConfig.ysnEscalation = 1))
		,strOwner = (select tblEMEntity.strName from tblEMEntity where tblEMEntity.intEntityId = (select top 1 tblHDGroupUserConfig.intUserSecurityEntityId from tblHDGroupUserConfig where tblHDGroupUserConfig.intTicketGroupId = tblHDTicketGroup.intTicketGroupId and tblHDGroupUserConfig.ysnOwner = 1))
	from
		tblHDTicketGroup
