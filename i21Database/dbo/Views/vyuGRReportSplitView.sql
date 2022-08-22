CREATE VIEW [dbo].[vyuGRReportSplitView]
	AS 


select 
	MainEntity.strName as strMainEntityName	
	, MainEntity.intEntityId
	, MainEntity.strEntityNo
	, Split.intSplitId
	, Split.strSplitNumber + '   -   ' + Split.strDescription as strSplitInfo 
	, EntitySplitDetail.strName as strSplitDetailName
	, SplitDetail.dblSplitPercent
	from tblEMEntitySplit Split
	join tblEMEntitySplitDetail SplitDetail
		on Split.intSplitId = SplitDetail.intSplitId
	join tblEMEntity EntitySplitDetail
		on SplitDetail.intEntityId = EntitySplitDetail.intEntityId
	join tblEMEntity MainEntity
		on Split.intEntityId = MainEntity.intEntityId
	--where Split.intEntityId = 11275
