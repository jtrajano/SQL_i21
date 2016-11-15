CREATE VIEW [dbo].[vyuPRForm941Report]
AS 

SELECT DISTINCT      
 intYear =					ISNULL(intYear, 0)          
 ,intQuarter =				ISNULL(intQuarter, 0)
 ,intEmployees =			/* box1 */ 
							ISNULL(intEmployees, 0)
 ,dblAdjustedGross =		/* box2 */ 
							CONVERT(NUMERIC(18,2), ISNULL(dblAdjustedGross, 0))        
 ,dblFIT =					/* box3 */ 
							CONVERT(NUMERIC(18,2), ISNULL(dblFIT, 0))  
 ,ysnNoTaxable =			/* box4 */
							ISNULL(ysnNoTaxable, 0)
 ,dblTaxableSS =			/* box5a1 */ 
							CONVERT(NUMERIC(18,2), ISNULL(dblTaxableSS, 0))           
 ,dblTotalTaxableSS =		/* box5a2 = box5a1 x 0.124 */ 
							CONVERT(NUMERIC(18,2), ISNULL(dblTaxableSS, 0) * 0.124)
 ,dblTaxableSSTips =		/* box5b1 */ 
							CONVERT(NUMERIC(18,2), ISNULL(dblTaxableSSTips, 0))
 ,dblTotalTaxableSSTips =	/* box5b2 = box5b1 x 0.124 */ 
							CONVERT(NUMERIC(18,2), ISNULL(dblTaxableSSTips, 0) * 0.124)
 ,dblTaxableMed =			/* box5c1 */ 
							CONVERT(NUMERIC(18,2), ISNULL(dblTaxableMed, 0))   
 ,dblTotalTaxableMed =		/* box5c2 = box5c1 x 0.029*/ 
							CONVERT(NUMERIC(18,2), ISNULL(dblTaxableMed, 0) * 0.029)
 ,dblTaxableAddMed =			/* box5c1 */ 
							CONVERT(NUMERIC(18,2), ISNULL(dblTaxableAddMed, 0))   
 ,dblTotalTaxableAddMed =		/* box5c2 = box5c1 x 0.029*/ 
							CONVERT(NUMERIC(18,2), ISNULL(dblTaxableAddMed, 0) * 0.009)
 ,dblTotalSSMed =			/* box5e = box5a2 + box5b2 + box5c2 + box5d2 */ 
							CONVERT(NUMERIC(18,2), (ISNULL(dblTaxableSS, 0) * 0.124) + (ISNULL(dblTaxableSSTips, 0) * 0.124) + (ISNULL(dblTaxableMed, 0) * 0.029) + (ISNULL(dblTaxableAddMed, 0) * 0.009))
 ,dblTaxDueUnreported =		/* box5f */ 
							CONVERT(NUMERIC(18,2), ISNULL(dblTaxDueUnreported, 0))
 ,dblAdjustSickPay =		/* box7 */ 
							CONVERT(NUMERIC(18,2), ISNULL(dblAdjustSickPay, 0))
 ,dblAdjustFractionCents =	/* box8 */ 
							CONVERT(NUMERIC(18,2), ISNULL(dblAdjustFractionCents, 0))
 ,dblAdjustTips =			/* box9 */ 
							CONVERT(NUMERIC(18,2), ISNULL(dblAdjustTips, 0))
 ,dblAdjustedToSSMed =		/* (total adjustments) = box7 + box8 + box9 */
							ISNULL(dblAdjustSickPay, 0) + ISNULL(dblAdjustFractionCents, 0) + ISNULL(dblAdjustTips, 0)
 ,dblAdjSSMedTaxes =		/* box5e + total adjustments */
							CONVERT(NUMERIC(18,2), (ISNULL(dblTaxableSS, 0) * 0.124) + (ISNULL(dblTaxableSSTips, 0) * 0.124) + (ISNULL(dblTaxableMed, 0) * 0.029) + (ISNULL(dblTaxableAddMed, 0) * 0.009))
							+ ISNULL(dblAdjustSickPay, 0) + ISNULL(dblAdjustFractionCents, 0) + ISNULL(dblAdjustTips, 0)
 ,dblTotalTaxes =			/* box6 = box3 + box5f + box5e */
							ISNULL(dblFIT, 0)
							+ ISNULL(dblTaxDueUnreported, 0)
							+ CONVERT(NUMERIC(18,2), (ISNULL(dblTaxableSS, 0) * 0.124) + (ISNULL(dblTaxableSSTips, 0) * 0.124) + (ISNULL(dblTaxableMed, 0) * 0.029) + (ISNULL(dblTaxableAddMed, 0) * 0.009))
 ,dblNetTaxes =				/* box10 = box6 + (total adjustments) */
							ISNULL(dblFIT, 0)
							+ CONVERT(NUMERIC(18,2), (ISNULL(dblTaxableSS, 0) * 0.124) + (ISNULL(dblTaxableSSTips, 0) * 0.124) + (ISNULL(dblTaxableMed, 0) * 0.029) + (ISNULL(dblTaxableAddMed, 0) * 0.009)) 
							+ ISNULL(dblTaxDueUnreported, 0)
							+ ISNULL(dblAdjustSickPay, 0) + ISNULL(dblAdjustFractionCents, 0) + ISNULL(dblAdjustTips, 0)
 ,dblTotalDeposit =			/* box11 */ 
							CONVERT(NUMERIC(18,2), ISNULL(dblTotalDeposit,0))
 ,dblBalanceDue =			/* box12 = if box10 > box 11 then box10 - box11 */
							CASE WHEN (CONVERT(NUMERIC(18,2), (ISNULL(dblTaxableSS, 0) * 0.124) + (ISNULL(dblTaxableSSTips, 0) * 0.124) + (ISNULL(dblTaxableMed, 0) * 0.029) + (ISNULL(dblTaxableAddMed, 0) * 0.009)) + ISNULL(dblFIT, 0) 
										+ CONVERT(NUMERIC(18,2), ISNULL(dblTaxDueUnreported, 0))
										+ ISNULL(dblAdjustSickPay, 0) + ISNULL(dblAdjustFractionCents, 0) + ISNULL(dblAdjustTips, 0)) > ISNULL(dblTotalDeposit,0)   
								 THEN (CONVERT(NUMERIC(18,2), (ISNULL(dblTaxableSS, 0) * 0.124) + (ISNULL(dblTaxableSSTips, 0) * 0.124) + (ISNULL(dblTaxableMed, 0) * 0.029) + (ISNULL(dblTaxableAddMed, 0) * 0.009)) + ISNULL(dblFIT, 0) 
										+ CONVERT(NUMERIC(18,2), ISNULL(dblTaxDueUnreported, 0))
										+ ISNULL(dblAdjustSickPay, 0) + ISNULL(dblAdjustFractionCents, 0) + ISNULL(dblAdjustTips, 0)) - ISNULL(dblTotalDeposit,0)
								 ELSE 0 END
 ,dblOverPayment =			/* box13 = if box10 < box 11 then box10 - box11 */
							CASE WHEN ISNULL(dblTotalDeposit,0) > (CONVERT(NUMERIC(18,2), (ISNULL(dblTaxableSS, 0) * 0.124) + (ISNULL(dblTaxableSSTips, 0) * 0.124) + (ISNULL(dblTaxableMed, 0) * 0.029) + (ISNULL(dblTaxableAddMed, 0) * 0.009)) + ISNULL(dblFIT, 0) 
										+ CONVERT(NUMERIC(18,2), ISNULL(dblTaxDueUnreported, 0))
										+ ISNULL(dblAdjustSickPay, 0) + ISNULL(dblAdjustFractionCents, 0) + ISNULL(dblAdjustTips, 0))
								 THEN ISNULL(dblTotalDeposit,0) - (CONVERT(NUMERIC(18,2), (ISNULL(dblTaxableSS, 0) * 0.124) + (ISNULL(dblTaxableSSTips, 0) * 0.124) + (ISNULL(dblTaxableMed, 0) * 0.029) + (ISNULL(dblTaxableAddMed, 0) * 0.009)) + ISNULL(dblFIT, 0) 
										+ CONVERT(NUMERIC(18,2), ISNULL(dblTaxDueUnreported, 0))
										+ ISNULL(dblAdjustSickPay, 0) + ISNULL(dblAdjustFractionCents, 0) + ISNULL(dblAdjustTips, 0))
								 ELSE 0 END
 ,ysnRefundOverpayment =	/* box13 */ 
							ysnRefundOverpayment
 ,ysn2500Less =				/* box14a */ 
							CONVERT(BIT, CASE WHEN ISNULL(intScheduleType, 1) = 0 THEN 1 ELSE 0 END)
 ,ysnMonthly =				/* box14b */ 
							CONVERT(BIT, CASE WHEN ISNULL(intScheduleType, 1) = 1 THEN 1 ELSE 0 END)
 ,ysnSemiWeekly =			/* box14c */ 
							CONVERT(BIT, CASE WHEN ISNULL(intScheduleType, 1) = 2 THEN 1 ELSE 0 END)
 ,dblMonth3 =				/* third month */
							CASE WHEN ISNULL(intScheduleType, 1) = 1 THEN dblMonth3 ELSE 0 END
 ,dblMonth2 =				/* second month */
							CASE WHEN ISNULL(intScheduleType, 1) = 1 THEN dblMonth2 ELSE 0 END
 ,dblMonth1 =				/* first month */
							CASE WHEN ISNULL(intScheduleType, 1) = 1 THEN dblMonth1 ELSE 0 END
 ,dblQuarter =				/* total liability for the quarter = month 1 + month 2 + month 3 */
							CASE WHEN ISNULL(intScheduleType, 1) = 1 THEN 
								CONVERT(NUMERIC(18,2), dblMonth1 + dblMonth2 + dblMonth3)
							ELSE 0 END
 ,ysnStoppedWages =			/* box15 */
							ysnStoppedWages
 ,dtmStoppedWages =			/* box15 date */
							dtmStoppedWages
 ,ysnSeasonalEmployer =		/* box16 */
							ysnSeasonalEmployer
 ,ysnAllowContactDesignee
 ,strDesigneeName =			CASE WHEN (ISNULL(ysnAllowContactDesignee, 0) = 1) THEN strDesigneeName ELSE '' END
 ,strDesigneePhone =		CASE WHEN (ISNULL(ysnAllowContactDesignee, 0) = 1) THEN strDesigneePhone ELSE '' END
 ,strDesigneePIN =			CASE WHEN (ISNULL(ysnAllowContactDesignee, 0) = 1) THEN strDesigneePIN ELSE '' END
 ,dtmSignDate
 ,strName
 ,strTitle
 ,strPhone
 ,strPreparerName
 ,strPreparerFirmName
 ,strPreparerAddress
 ,strPreparerCity
 ,strPreparerState
 ,ysnSelfEmployed
 ,strPreparerPTIN
 ,dtmPreparerSignDate
 ,strPreparerEIN
 ,strPreparerPhone
 ,strPreparerZip
 ,dblPaymentDollars
 ,dblPaymentCents
FROM
tblPRForm941
