GO
IF EXISTS(select top 1 1 from sys.procedures where name = 'uspSMImportTaxClass')
	DROP PROCEDURE uspSMImportTaxClass
GO

CREATE PROCEDURE uspSMImportTaxClass
	@Checking BIT = 0,
	@Total INT = 0 OUTPUT

	AS
BEGIN
	--================================================
	--     ONE TIME TERM SYNCHRONIZATION	
	--================================================

	DECLARE @ysnAG BIT = 0
    DECLARE @ysnPT BIT = 0

	SELECT TOP 1 @ysnAG = CASE WHEN ISNULL(coctl_ag, '') = 'Y' THEN 1 ELSE 0 END
			   , @ysnPT = CASE WHEN ISNULL(coctl_pt, '') = 'Y' THEN 1 ELSE 0 END 
	FROM coctlmst	

	
	
	if object_id('tempdb..#tmpTaxClass') is not null
		drop table #tmpTaxClass


	create table #tmpTaxClass
	(
		id			int identity(1,1),
		strTaxClass nvarchar(100)
	)

	IF @ysnAG = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'aglclmst')
	BEGIN

		insert into #tmpTaxClass(strTaxClass)
		select distinct(aglcl_lc1_ivc_desc) from aglclmst where aglcl_lc1_ivc_desc is Not Null 
		union 
		select distinct(aglcl_lc2_ivc_desc) from aglclmst where aglcl_lc2_ivc_desc is Not Null
		union 
		select distinct(aglcl_lc3_ivc_desc) from aglclmst where aglcl_lc3_ivc_desc is Not Null
		union 
		select distinct(aglcl_lc4_ivc_desc) from aglclmst where aglcl_lc4_ivc_desc is Not Null
		union 
		select distinct(aglcl_lc5_ivc_desc) from aglclmst where aglcl_lc5_ivc_desc is Not Null
		union 
		select distinct(aglcl_lc6_ivc_desc) from aglclmst where aglcl_lc6_ivc_desc is Not Null			

	END
	IF @ysnPT = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'ptlclmst')
	BEGIN
		insert into #tmpTaxClass(strTaxClass)
		select distinct(ptlcl_local1_desc) from ptlclmst where ptlcl_local1_desc is Not Null 
		union 
		select distinct(ptlcl_local2_desc) from ptlclmst where ptlcl_local2_desc is Not Null
		union 
		select distinct(ptlcl_local3_desc) from ptlclmst where ptlcl_local3_desc is Not Null
		union 
		select distinct(ptlcl_local4_desc) from ptlclmst where ptlcl_local4_desc is Not Null
		union 
		select distinct(ptlcl_local5_desc) from ptlclmst where ptlcl_local5_desc is Not Null
		union 
		select distinct(ptlcl_local6_desc) from ptlclmst where ptlcl_local6_desc is Not Null
		union 
		select distinct(ptlcl_local7_desc) from ptlclmst where ptlcl_local7_desc is Not Null
		union 
		select distinct(ptlcl_local8_desc) from ptlclmst where ptlcl_local8_desc is Not Null
		union 
		select distinct(ptlcl_local9_desc) from ptlclmst where ptlcl_local9_desc is Not Null
		union 
		select distinct(ptlcl_local10_desc) from ptlclmst where ptlcl_local10_desc is Not Null
		union 
		select distinct(ptlcl_local11_desc) from ptlclmst where ptlcl_local11_desc is Not Null
		union 
		select distinct(ptlcl_local12_desc) from ptlclmst where ptlcl_local12_desc is Not Null
	END



	IF(@Checking = 0) 
	BEGIN
		
		--1 Time synchronization here
		PRINT '1 Time tax class Synchronization'
				

		IF @ysnAG = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'aglclmst')
		BEGIN
			insert into tblSMTaxClass(strTaxClass)
			select a.strTaxClass 
				from #tmpTaxClass a
				LEFT join tblSMTaxClass b
					on a.strTaxClass COLLATE Latin1_General_CI_AS = b.strTaxClass COLLATE Latin1_General_CI_AS 
			where b.intTaxClassId is null		
		END
		IF @ysnPT = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'ptlclmst')
		BEGIN
			insert into tblSMTaxClass(strTaxClass)
			select a.strTaxClass 
				from #tmpTaxClass a
				LEFT join tblSMTaxClass b
					on a.strTaxClass COLLATE Latin1_General_CI_AS = b.strTaxClass COLLATE Latin1_General_CI_AS 
			where b.intTaxClassId is null		
		END
	END

	
	IF(@Checking = 1) 
	 BEGIN
		IF @ysnAG = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'aglclmst')
		 BEGIN
			 select @Total = Count(a.id) 			
				from #tmpTaxClass a
				LEFT join tblSMTaxClass b
					on a.strTaxClass COLLATE Latin1_General_CI_AS = b.strTaxClass COLLATE Latin1_General_CI_AS 
			where b.intTaxClassId is null
		 END

		IF @ysnPT = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'ptlclmst')
		 BEGIN			
			select @Total = Count(a.id) 			
				from #tmpTaxClass a
				LEFT join tblSMTaxClass b
					on a.strTaxClass COLLATE Latin1_General_CI_AS = b.strTaxClass COLLATE Latin1_General_CI_AS 
			where b.intTaxClassId is null
		 END		
	 END	
END