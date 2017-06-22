CREATE PROCEDURE [dbo].[uspPATImportCompanyPreference]
AS
BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

	DECLARE @RefundInd CHAR(1), 
	@RefundMinAmt DECIMAL(5, 2), 
	@ServiceFee DECIMAL(5, 2),
	@CutOffAmt DECIMAL(5, 2),
	@CutOffCashEquity NVARCHAR(20), 
	@GaPayStlInd NVARCHAR(20),
	@ChkPrtYN CHAR(1), 
	@MinDivAmt DECIMAL(5, 2),
	@ProrateDiv BIT, 
	@ProrateCutOffDt DATETIME,
	@VotingGLId INT,
	@NonVotingGLId INT, 
	@FracShareGLId INT,
	@ServiceFeeGLId INT;

	---------------------------- BEGIN - COLUMN ASSIGNMENTS ----------------------------------------------
	SET @RefundInd = (SELECT pactl_refund_ind from pactlmst where pactl_key = 01);
	SET @RefundMinAmt = (SELECT pactl_min_rfd_amt from pactlmst where pactl_key = 01);
	SET @ServiceFee = (SELECT pactl_srv_fee_amt from pactlmst where pactl_key = 01);
	SET @CutOffAmt = (SELECT pactl_cutoff_amt from pactlmst where pactl_key = 01);
	SET @CutOffCashEquity = CASE (SELECT pactl_cutoff_cash_equity from pactlmst where pactl_key = 01) WHEN 'C' THEN 'Cash' WHEN 'E' THEN 'Equity' END;
	SET @GaPayStlInd = CASE (SELECT pactl_ga_pay_stl_ind from pactlmst where pactl_key = 01) WHEN 'P' THEN 'Paid' WHEN 'S' THEN 'Settled' END;
	SET @ChkPrtYN = CASE (SELECT pactl_chk_prt_yn from pactlmst where pactl_key = 01) WHEN 'Y' THEN 'A' WHEN 'N' THEN 'M' END;
	SET @MinDivAmt = (SELECT pactl_min_div_amt from pactlmst where pactl_key = 01);
	SET @ProrateDiv = CASE (SELECT pactl_prorate_div_yn from pactlmst where pactl_key = 01) WHEN 'Y' THEN 1 WHEN 'N' THEN 0 END;
	SET @ProrateCutOffDt = CASE WHEN (SELECT pactl_prorate_cutoff_rev_dt from pactlmst where pactl_key = 01) != 0 THEN 
		(SELECT (CONVERT (DATETIME, CAST (pactl_prorate_cutoff_rev_dt AS CHAR (12)), 112)) from pactlmst where pactl_key = 01)
		ELSE NULL END;
	SET @VotingGLId = (SELECT GL.intAccountId FROM pactlmst PACT 
						LEFT OUTER JOIN glactmst GLACT ON GLACT.glact_acct1_8 = FLOOR(PACT.pact3_gl_vote_stk_iss) AND GLACT.glact_acct9_16 = RIGHT(PACT.pact3_gl_vote_stk_iss, 8)
						OUTER APPLY (SELECT TOP 1 GL.intAccountId FROM tblGLAccount GL WHERE GL.strDescription LIKE '%' + RTRIM(GLACT.glact_desc) COLLATE Latin1_General_CI_AS + '%') GL
						WHERE PACT.pactl_key ='03');
	SET @NonVotingGLId = (SELECT GL.intAccountId FROM pactlmst PACT 
						LEFT OUTER JOIN glactmst GLACT ON GLACT.glact_acct1_8 = FLOOR(PACT.pact3_gl_non_vote_stk_iss) AND GLACT.glact_acct9_16 = RIGHT(PACT.pact3_gl_non_vote_stk_iss, 8)
						OUTER APPLY (SELECT TOP 1 GL.intAccountId FROM tblGLAccount GL WHERE GL.strDescription LIKE '%' + RTRIM(GLACT.glact_desc) COLLATE Latin1_General_CI_AS + '%') GL
						WHERE PACT.pactl_key ='03');
	SET @FracShareGLId = (SELECT GL.intAccountId FROM pactlmst PACT 
						LEFT OUTER JOIN glactmst GLACT ON GLACT.glact_acct1_8 = FLOOR(PACT.pact3_gl_frac_shares) AND GLACT.glact_acct9_16 = RIGHT(PACT.pact3_gl_frac_shares, 8)
						OUTER APPLY (SELECT TOP 1 GL.intAccountId FROM tblGLAccount GL WHERE GL.strDescription LIKE '%' + RTRIM(GLACT.glact_desc) COLLATE Latin1_General_CI_AS + '%') GL
						WHERE PACT.pactl_key ='03');
	SET @ServiceFeeGLId = (SELECT GL.intAccountId FROM pactlmst PACT 
						LEFT OUTER JOIN glactmst GLACT ON GLACT.glact_acct1_8 = FLOOR(PACT.pact3_gl_srv_fee) AND GLACT.glact_acct9_16 = RIGHT(PACT.pact3_gl_srv_fee, 8)
						OUTER APPLY (SELECT TOP 1 GL.intAccountId FROM tblGLAccount GL WHERE GL.strDescription LIKE '%' + RTRIM(GLACT.glact_desc) COLLATE Latin1_General_CI_AS + '%') GL
						WHERE PACT.pactl_key ='03');
	---------------------------- END - COLUMN ASSIGNMENTS ----------------------------------------------


	---------------------------- BEGIN - UPDATE COMPANY PREFERENCE FROM ORIGIN ----------------------------------------------
	IF EXISTS(SELECT 1 FROM tblPATCompanyPreference)
	BEGIN
	UPDATE	tblPATCompanyPreference SET 
			strRefund = @RefundInd,
			dblMinimumRefund = @RefundMinAmt,
			dblServiceFee = @ServiceFee,
			dblCutoffAmount = @CutOffAmt,
			strCutoffTo = @CutOffCashEquity,
			strPayOnGrain = @GaPayStlInd,
			strPrintCheck = @ChkPrtYN,
			dblMinimumDividends = @MinDivAmt,
			ysnProRatedDividends = @ProrateDiv,
			dtmCutoffDate = @ProrateCutOffDt,
			intVotingStockId = @VotingGLId,
			intNonVotingStockId = @NonVotingGLId,
			intFractionalShareId = @FracShareGLId,
			intServiceFeeIncomeId = @ServiceFeeGLId
	WHERE intCompanyPreferenceId = 1
	END
	ELSE
	BEGIN
		INSERT INTO tblPATCompanyPreference(strRefund, dblMinimumRefund, dblServiceFee, dblCutoffAmount, strCutoffTo, strPayOnGrain, strPrintCheck, dblMinimumDividends, ysnProRatedDividends, dtmCutoffDate, intVotingStockId, intNonVotingStockId, intFractionalShareId, intServiceFeeIncomeId, intConcurrencyId)
		VALUES(@RefundInd, @RefundMinAmt, @ServiceFee, @CutOffAmt, @CutOffCashEquity, @GaPayStlInd, @ChkPrtYN, @MinDivAmt, @ProrateDiv, @ProrateCutOffDt, @VotingGLId, @NonVotingGLId, @FracShareGLId, @ServiceFeeGLId, 1)
	END
	---------------------------- END - UPDATE COMPANY PREFERENCE FROM ORIGIN ----------------------------------------------
END