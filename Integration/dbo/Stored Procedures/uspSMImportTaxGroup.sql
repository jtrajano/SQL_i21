GO
IF EXISTS(select top 1 1 from sys.procedures where name = 'uspSMImportTaxGroup')
	DROP PROCEDURE uspSMImportTaxGroup
GO

CREATE PROCEDURE uspSMImportTaxGroup
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

	declare @tax_group_table table (
		strGroup		nvarchar(50),
		strDescription	nvarchar(50)
	)

	IF @ysnPT = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'ptlclmst')
	BEGIN
		
		
		insert into @tax_group_table(strGroup, strDescription)
		select 
						isnull(a.ptlcl_state,'') + ' ' + isnull(a.ptlcl_local1_id,'') + ' ' + ISNULL(a.ptlcl_local2_id,'')
						, isnull(a.ptlcl_desc, '')
					from ptlclmst a
						left join tblSMTaxGroup b
							on (isnull(a.ptlcl_state,'') + ' ' 
							+ isnull(a.ptlcl_local1_id,'') + ' ' 
							+ ISNULL(a.ptlcl_local2_id,'')  ) COLLATE Latin1_General_CI_AS =  b.strTaxGroup  COLLATE Latin1_General_CI_AS
					where b.intTaxGroupId is null

		insert into @tax_group_table(strGroup, strDescription)
		select 
			distinct(isnull(ssvnc_seq_cd,'') + ' ' + isnull(ssvnc_tx_auth_id1,'') + ' ' + ISNULL(ssvnc_tx_auth_id2,'')) as strTaxGroup
			,'Origin Tax Group' as strOriginDescription
		from ssvncmst a
			left join tblSMTaxGroup b
				on (isnull(a.ssvnc_seq_cd,'') + ' ' 
				+ isnull(a.ssvnc_tx_auth_id1,'') + ' ' 
				+ ISNULL(a.ssvnc_tx_auth_id2,'')  ) COLLATE Latin1_General_CI_AS =  b.strTaxGroup  COLLATE Latin1_General_CI_AS
			where ltrim(rtrim(( isnull(ssvnc_seq_cd,'') + ' ' + isnull(ssvnc_tx_auth_id1,'') + ' ' + ISNULL(ssvnc_tx_auth_id2,'') ))) <> ''
				and b.intTaxGroupId is null
				and ltrim(rtrim(( isnull(ssvnc_seq_cd,'') + ' ' + isnull(ssvnc_tx_auth_id1,'') + ' ' + ISNULL(ssvnc_tx_auth_id2,'') ))) not in ( select strGroup from @tax_group_table)



	END
	IF(@Checking = 0) 
	BEGIN
		
		--1 Time synchronization here
		PRINT '1 Time Term Synchronization'
		
		DECLARE @intTermId			INT
		DECLARE @strTerm			NVARCHAR(200)
		DECLARE @strTermCode		NVARCHAR(10)
		DECLARE @strType			NVARCHAR(50)
		DECLARE @dblDiscountEP		NUMERIC(18,6)
		DECLARE @intDiscountDay		INT
		DECLARE @dtmDiscountDate	DATETIME
		DECLARE @intBalanceDue		INT
		DECLARE @dtmDueDate			DATETIME
		DECLARE @ysnAllowEFT		BIT
		DECLARE @isTermExists		BIT

		

		IF @ysnAG = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'aglclmst')
		BEGIN
			INSERT INTO tblSMTaxGroup(strTaxGroup, strDescription)
			select 
				isnull(a.aglcl_tax_state,'') + ' ' + isnull(a.aglcl_tax_auth_id1,'') + ' ' + ISNULL(a.aglcl_tax_auth_id2,'')
				,isnull(a.aglcl_auth_id1_desc, '') + ' ' +  isnull(a.aglcl_auth_id2_desc, '') OriginTaxDescription 
			from aglclmst a
				left join tblSMTaxGroup b
					on (isnull(a.aglcl_tax_state,'') + ' ' 
					+ isnull(a.aglcl_tax_auth_id1,'') + ' ' 
					+ ISNULL(a.aglcl_tax_auth_id2,'')  ) COLLATE Latin1_General_CI_AS =  b.strTaxGroup  COLLATE Latin1_General_CI_AS
			where b.intTaxGroupId is null				
		END
		IF @ysnPT = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'ptlclmst')
		BEGIN
			insert into tblSMTaxGroup(strTaxGroup, strDescription) select strGroup, strDescription from @tax_group_table order by strGroup
		END

		 EXEC [uspARImportTaxGroupDetail]		
	END

	
	IF(@Checking = 1) 
	 BEGIN
		IF @ysnAG = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'aglclmst')
		 BEGIN

			 select @Total = Count(a.A4GLIdentity)
				from aglclmst a
					left join tblSMTaxGroup b
						on (isnull(a.aglcl_tax_state,'') + ' ' 
						+ isnull(a.aglcl_tax_auth_id1,'') + ' ' 
						+ ISNULL(a.aglcl_tax_auth_id2,'')  ) COLLATE Latin1_General_CI_AS =  b.strTaxGroup  COLLATE Latin1_General_CI_AS
				where b.intTaxGroupId is null
		 END

		IF @ysnPT = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'ptlclmst')
		 BEGIN			
			select @Total = count(strGroup) from @tax_group_table
		 END
		 
		
	 END	
END
