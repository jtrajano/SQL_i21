CREATE PROCEDURE [dbo].[uspNRGetDetailsForInvoice]
@intNoteId int
As
BEGIN


-- Get Invoice List
	
	DECLARE @intCustomerId int, @blnSwitchOrigini21 bit, @strOriginSystem nvarchar(5), @strVersionNumber nvarchar(6)
			, @strCustomerNumber nvarchar(50)
	SELECT @blnSwitchOrigini21 = strValue FROM dbo.tblSMPreferences WHERE strPreference = 'nrSwitchOrigini21'
	SELECT @strOriginSystem = strValue FROM dbo.tblSMPreferences WHERE strPreference = 'nrOriginSystem'			
	SELECT @strVersionNumber = strValue FROM dbo.tblSMPreferences WHERE strPreference = 'nrVersionNumber'						
	SELECT @intCustomerId = intCustomerId FROM dbo.tblNRNote WHERE intNoteId = @intNoteId

	IF @blnSwitchOrigini21 = 1
	BEGIN
		SELECT @strCustomerNumber = strCustomerNumber FROM dbo.tblARCustomer Where [intEntityCustomerId] = @intCustomerId
		
		IF @strOriginSystem = 'PT'
		BEGIN
			IF @strVersionNumber = '15.1'
			BEGIN
				SELECT * FROM 
				(
					Select DISTINCT CAST(ROW_NUMBER() 
						OVER (ORDER BY a.ptivc_invc_no) AS Int)  AS [intInvoiceId]
					, a.ptivc_invc_no [strInvoiceNumber]
					, CONVERT(Date, CAST(a.ptivc_rev_dt as nvarchar ))  [dtmDate]
					, CASE WHEN a.ptivc_type = 'I'  
							THEN (isnull(a.ptivc_bal_due,0) ) --  - isnull(b.ptpye_amt,0)) 
							ELSE (isnull(c.ptcrd_amt,0) - isnull(c.ptcrd_amt_used,0) ) --  - isnull(b.ptpye_amt,0)) 
					  END  [dblAmount] 
					, CAST(a.ptivc_loc_no as int)  AS intCompanyLocationId
					, l.ptloc_name [strLocationName]
					, CASE WHEN a.ptivc_type = 'I' 
							THEN 'Invoice' 
							ELSE 'CREDIT MEMO' 
					  END [strType]
					, CAST(0 as bit) [blnChk]
					FROM  ptivcmst a 
					LEFT OUTER JOIN ptcrdmst c ON a.ptivc_cus_no = c.ptcrd_cus_no AND a.ptivc_invc_no = c.ptcrd_invc_no 
							AND a.ptivc_loc_no = c.ptcrd_loc_no   
					--LEFT OUTER JOIN ptpyemst b ON a.ptivc_cus_no = b.ptpye_cus_no AND a.ptivc_invc_no = b.ptpye_inc_ref 
					--		AND a.ptivc_loc_no = b.ptpye_ivc_loc_no 
					LEFT JOIN ptlocmst l ON l.ptloc_loc_no = a.ptivc_loc_no					
					WHERE (a.ptivc_type IN ('I', 'C')) AND (a.ptivc_cus_no= @strCustomerNumber)
					AND a.ptivc_invc_no not in (Select ptpye_inc_ref FROM ptpyemst)
				) x WHERE x.dblAmount <> 0
			END			
		END
		
		If @strOriginSystem = 'AG'
		BEGIN
			IF @strVersionNumber = '15.1'
			BEGIN
				SELECT * FROM 
				(
					Select DISTINCT CAST(ROW_NUMBER() 
						OVER (ORDER BY a.agivc_ivc_no) AS Int)  [intInvoiceId]
					, a.agivc_ivc_no [strInvoiceNumber]
					, CONVERT(Date, CAST(a.agivc_rev_dt as nvarchar ))  [dtmDate]
					, CASE WHEN a.agivc_type = 'I'  
							THEN (isnull(a.agivc_bal_due,0) ) --    - isnull(b.agpye_amt,0)) 
							ELSE (isnull(c.agcrd_amt,0) - isnull(c.agcrd_amt_used,0) ) --  - isnull(b.agpye_amt,0)) 
					  END  [dblAmount] 
					, CAST(a.agivc_loc_no as int)  AS intCompanyLocationId
					, l.agloc_name [strLocationName]
					, CASE WHEN a.agivc_type = 'I' 
							THEN 'Invoice' 
							ELSE 'CREDIT MEMO' 
					  END [strType]
					, CAST(0 as bit) [blnChk]			
					FROM  agivcmst a 
					LEFT OUTER JOIN agcrdmst c ON a.agivc_bill_to_cus = c.agcrd_cus_no AND a.agivc_ivc_no = c.agcrd_ref_no 
							AND a.agivc_loc_no = c.agcrd_loc_no   
					--LEFT OUTER JOIN agpyemst b ON a.agivc_bill_to_cus = b.agpye_cus_no AND a.agivc_ivc_no = b.agpye_inc_ref 
					--		AND a.agivc_loc_no = b.agpye_ivc_loc_no 
					LEFT JOIN aglocmst l ON l.agloc_loc_no = a.agivc_loc_no					
					WHERE (a.agivc_type IN ('I', 'C')) AND (a.agivc_bill_to_cus= @strCustomerNumber)
					AND a.agivc_ivc_no not in (Select agpye_inc_ref From agpyemst)
				)  x WHERE x.dblAmount <> 0
			END			
		END		
		
	END
	ELSE
	BEGIN
		SELECT * FROM 
		(
			SELECT intInvoiceId 
			, strInvoiceNumber	-- Invoice Number
			,dtmDate			-- Invoice Date
			,(CASE WHEN strTransactionType = 'I' THEN ISNULL((dblAmountDue - dblPayment),0) ELSE 0 END) [dblAmount]
			, I.intCompanyLocationId 
			, CL.strLocationName
			, (CASE WHEN strTransactionType = 'I' THEN 'Invoice' ELSE 'CREDIT MEMO' END) [strType]
			, CAST(0 as bit) [blnChk]
			FROM dbo.tblARInvoice I
			JOIN dbo.tblSMCompanyLocation CL ON CL.intCompanyLocationId = I.intCompanyLocationId
			WHERE I.intCustomerId = @intCustomerId AND strTransactionType in ('I', 'C')
		) x WHERE x.dblAmount <> 0
	END
	

--Get latest Principal
	SELECT top 1 dblPrincipal FROM dbo.tblNRNoteTransaction WHERE intNoteId = @intNoteId ORDER BY intNoteTransId DESC

--Get latest, incremented sreRefNo
	DECLARE @intRefNo int, @intCnt int, @strRefNo nvarchar(20)
	Select @intCnt = COUNT(strRefNo) FROM [dbo].tblNRNoteTransaction where intNoteTransTypeId=1 -- Order by intNoteTransId desc

	IF @intCnt = 0
		SET @strRefNo = 'NX0001'
	ELSE
	BEGIN
		Select top 1 @strRefNo = strRefNo FROM [dbo].tblNRNoteTransaction where intNoteTransTypeId=1  Order by intNoteTransId desc
		--SET @strRefNo = 'NX00024'
		Select @strRefNo = SUBSTRING(@strRefNo, 3,(LEN(@strRefNo) - 2))--FROM [dbo].tblNRNoteTransaction where intNoteTransTypeId=1  Order by intNoteTransId desc
		SET @intRefNo = @strRefNo
		
		select  @strRefNo = 'NX' + REPLICATE('0',4-LEN(@intRefNo+1))  + cast((@intRefNo+1) as nvarchar(5))

	END	

	SELECT @strRefNo [strRefNo] 
	
	Select dtmCreated from dbo.tblNRNote Where intNoteId = @intNoteId
	
	SELECT TOP 1 dtmNoteTranDate FROM dbo.tblNRNoteTransaction WHERE intNoteId = @intNoteId AND intNoteTransTypeId = 3 ORDER BY intNoteTransId DESC
	
END