DECLARE @TemplateId NVARCHAR(250)

DELETE FROM tblTFTaxReportTemplate WHERE strTemplateItemId IS NULL
OR strTemplateItemId = 'TID' OR strTemplateItemId = 'License Number' 
OR strTemplateItemId = 'Filing Type' 
OR strTemplateItemId = 'License Holder Name' 
OR strTemplateItemId = 'TaxPayerName'

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'MF-360-FilingType-001')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (NULL, N'MF-360-FilingType-001', N'MF-360', 14, N'IN', N'1', 0, 0, N'Filing Type', N'', NULL, 0, NULL, N'Filing Type', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = 'Filing Type' WHERE strTemplateItemId = 'MF-360-FilingType-001'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'MF-360-Summary-001')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (NULL, N'MF-360-Summary-001', N'MF-360', 14, N'IN', N'Section 2:    Calculation of Gasoline Taxes Due', 1, 1, N'1. Total receipts (From Section A, Line 8, Column D on back of return)', N'1A,2,2K,2X,3,4', NULL, 0, NULL, N'Summary', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '1. Total receipts (From Section A, Line 8, Column D on back of return)' WHERE strTemplateItemId = 'MF-360-Summary-001'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'MF-360-Summary-002')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (NULL, N'MF-360-Summary-002', N'MF-360', 14, N'IN', N'Section 2:    Calculation of Gasoline Taxes Due', 2, 2, N'2. Total non-taxable disbursements (From Section B, Line 10, Column D on back of return)', N'11,6D,6X,7,8,10A,10B', NULL, 0, NULL, N'Summary', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '2. Total non-taxable disbursements (From Section B, Line 10, Column D on back of return)' WHERE strTemplateItemId = 'MF-360-Summary-002'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'MF-360-Summary-003')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (NULL, N'MF-360-Summary-003', N'MF-360', 14, N'IN', N'Section 2:    Calculation of Gasoline Taxes Due', 3, 3, N'3. Gallons received, gasoline tax paid (From Section A, Line 1, Column A on back of return)', N'1A', NULL, 0, NULL, N'Summary', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '3. Gallons received, gasoline tax paid (From Section A, Line 1, Column A on back of return)' WHERE strTemplateItemId = 'MF-360-Summary-003'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'MF-360-Summary-004')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (NULL, N'MF-360-Summary-004', N'MF-360', 14, N'IN', N'Section 2:    Calculation of Gasoline Taxes Due', 4, 4, N'4.  Billed taxable gallons (Line 1 minus Line 2 minus Line 3)', N'1,2,3', NULL, 0, NULL, N'Summary', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '4.  Billed taxable gallons (Line 1 minus Line 2 minus Line 3)' WHERE strTemplateItemId = 'MF-360-Summary-004'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'MF-360-Summary-005')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (40, N'MF-360-Summary-005', N'MF-360', 14, N'IN', N'Section 2:    Calculation of Gasoline Taxes Due', 5, 5, N'5. Licensed gasoline distributor deduction (Multiply Line 4 by 0.016)', N'4', N'1.034', 1, NULL, N'Summary', 10, 6)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '5. Licensed gasoline distributor deduction (Multiply Line 4 by 0.016)' WHERE strTemplateItemId = 'MF-360-Summary-005'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'MF-360-Summary-006')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (NULL, N'MF-360-Summary-006', N'MF-360', 14, N'IN', N'Section 2:    Calculation of Gasoline Taxes Due', 6, 6, N'6. Billed taxable gallons (Line 4 minus Line 5)', N'4,5', NULL, 0, NULL, N'Summary', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '6. Billed taxable gallons (Line 4 minus Line 5)' WHERE strTemplateItemId = 'MF-360-Summary-006'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'MF-360-Summary-007')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (40, N'MF-360-Summary-007', N'MF-360', 14, N'IN', N'Section 2:    Calculation of Gasoline Taxes Due', 7, 7, N'7. Gasoline tax due (Multiply Line 6 by $0.18)', N'6', N'16', 1, NULL, N'Summary', 20, 7)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '7. Gasoline tax due (Multiply Line 6 by $0.18)' WHERE strTemplateItemId = 'MF-360-Summary-007'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'MF-360-Summary-008')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (40, N'MF-360-Summary-008', N'MF-360', 14, N'IN', N'Section 2:    Calculation of Gasoline Taxes Due', 8, 8, N'8. Adjustments (Schedule E-1 must be attached and is subject to Department approval)', N'0', N'3333', 1, NULL, N'Summary', 25, 1)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '8. Adjustments (Schedule E-1 must be attached and is subject to Department approval)' WHERE strTemplateItemId = 'MF-360-Summary-008'
		END
	
SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'MF-360-Summary-009')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
				VALUES (NULL, N'MF-360-Summary-009', N'MF-360', 14, N'IN', N'Section 2:    Calculation of Gasoline Taxes Due', 9, 9, N'9. Total gasoline tax due (Line 7 plus or minus Line 8)', N'7,8', NULL, 0, NULL, N'Summary', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '9. Total gasoline tax due (Line 7 plus or minus Line 8)' WHERE strTemplateItemId = 'MF-360-Summary-009'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'MF-360-Summary-010')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (NULL, N'MF-360-Summary-010', N'MF-360', 14, N'IN', N'Section 3:    Calculation of Oil Inspection Fees Due', 1, 10, N'1. Total receipts (From Section A, Line 9, Coumn D on back of return)', N'1A,2,2K,2X,3,4', NULL, 0, NULL, N'Summary', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '1. Total receipts (From Section A, Line 9, Coumn D on back of return)' WHERE strTemplateItemId = 'MF-360-Summary-010'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'MF-360-Summary-011')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (NULL, N'MF-360-Summary-011', N'MF-360', 14, N'IN', N'Section 3:    Calculation of Oil Inspection Fees Due', 2, 11, N'2. Total non-taxable disbursements (From Section B, Line 11, Column D on back of return)', N'11,6D,6X,7,8', NULL, 0, NULL, N'Summary', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '2. Total non-taxable disbursements (From Section B, Line 11, Column D on back of return)' WHERE strTemplateItemId = 'MF-360-Summary-011'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'MF-360-Summary-012')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (NULL, N'MF-360-Summary-012', N'MF-360', 14, N'IN', N'Section 3:    Calculation of Oil Inspection Fees Due', 3, 12, N'3. Gallons received, oil inspection fee paid (From Section A, Line 1, Column D on back of return)', N'1A', NULL, 0, NULL, N'Summary', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '3. Gallons received, oil inspection fee paid (From Section A, Line 1, Column D on back of return)' WHERE strTemplateItemId = 'MF-360-Summary-012'
		END
	
SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'MF-360-Summary-013')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (NULL, N'MF-360-Summary-013', N'MF-360', 14, N'IN', N'Section 3:    Calculation of Oil Inspection Fees Due', 4, 13, N'4. Billed taxable gallons (Line 1 minus Line 2 minus Line 3)', N'10,11,12', NULL, 0, NULL, N'Summary', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '4. Billed taxable gallons (Line 1 minus Line 2 minus Line 3)' WHERE strTemplateItemId = 'MF-360-Summary-013'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'MF-360-Summary-014')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
				VALUES (40, N'MF-360-Summary-014', N'MF-360', 14, N'IN', N'Section 3:    Calculation of Oil Inspection Fees Due', 5, 14, N'5. Oil inspection fees due (Multiply Line 4 by $0.01)', N'13', N'0.14', 1, NULL, N'Summary', 30, 5)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '5. Oil inspection fees due (Multiply Line 4 by $0.01)' WHERE strTemplateItemId = 'MF-360-Summary-014'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'MF-360-Summary-015')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (40, N'MF-360-Summary-015', N'MF-360', 14, N'IN', N'Section 3:    Calculation of Oil Inspection Fees Due', 6, 15, N'6. Adjustments (Schedule E-1 must be attached and is subject to Department approval)', N'15', N'123', 1, NULL, N'Summary', 32, 2)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '6. Adjustments (Schedule E-1 must be attached and is subject to Department approval)' WHERE strTemplateItemId = 'MF-360-Summary-015'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'MF-360-Summary-016')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId])
			VALUES (NULL, N'MF-360-Summary-016', N'MF-360', 14, N'IN', N'Section 3:    Calculation of Oil Inspection Fees Due', 7, 16, N'7. Total oil inspection fees due (Line 5 plus or minus Line 6)', N'14,15', NULL, 0, NULL, N'Summary', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '7. Total oil inspection fees due (Line 5 plus or minus Line 6)' WHERE strTemplateItemId = 'MF-360-Summary-016'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'MF-360-Summary-017')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (NULL, N'MF-360-Summary-017', N'MF-360', 14, N'IN', N'Section 4:    Calculation of Total Amount Due', 1, 17, N'1. Total amount due (Section 2, Line 9 plus Section 3, Line 7)', N'9,16', NULL, 0, NULL, N'Summary', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '1. Total amount due (Section 2, Line 9 plus Section 3, Line 7)' WHERE strTemplateItemId = 'MF-360-Summary-017'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'MF-360-Summary-018')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
				VALUES (40, N'MF-360-Summary-018', N'MF-360', 14, N'IN', N'Section 4:    Calculation of Total Amount Due', 2, 18, N'2. Penalty (Penalty must be added if report is filed after the due date. 10% of tax due or $5.00, whichever is greater. Five dollars ($5.00) is due on a late report showing no tax due.)', N'18', N'321', 1, NULL, N'Summary', 33, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '2. Penalty (Penalty must be added if report is filed after the due date. 10% of tax due or $5.00, whichever is greater. Five dollars ($5.00) is due on a late report showing no tax due.)' WHERE strTemplateItemId = 'MF-360-Summary-018'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'MF-360-Summary-019')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (40, N'MF-360-Summary-019', N'MF-360', 14, N'IN', N'Section 4:    Calculation of Total Amount Due', 3, 19, N'3. Interest (Interest must be added if report is filed after the due date. Contact the Department for daily interest rates.)', N'19', N'0', 1, NULL, N'Summary', 34, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '3. Interest (Interest must be added if report is filed after the due date. Contact the Department for daily interest rates.)' WHERE strTemplateItemId = 'MF-360-Summary-019'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'MF-360-Summary-020')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (NULL, N'MF-360-Summary-020', N'MF-360', 14, N'IN', N'Section 4:    Calculation of Total Amount Due', 4, 20, N'4. Net tax due (Line 1 plus Line 2 plus Line 3)', N'17,18,19', NULL, 0, NULL, N'Summary', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '4. Net tax due (Line 1 plus Line 2 plus Line 3)' WHERE strTemplateItemId = 'MF-360-Summary-020'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'MF-360-Summary-021')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (40, N'MF-360-Summary-021', N'MF-360', 14, N'IN', N'Section 4:    Calculation of Total Amount Due', 5, 21, N'5. Payment(s)', N'0', N'0', 1, NULL, N'Summary', 35, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '5. Payment(s)' WHERE strTemplateItemId = 'MF-360-Summary-021'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'MF-360-Summary-022')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (NULL, N'MF-360-Summary-022', N'MF-360', 14, N'IN', N'Section 4:    Calculation of Total Amount Due', 6, 22, N'6. Balance due (Line 4 minus Line 5)', N'20,21', NULL, 0, NULL, N'Summary', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '6. Balance due (Line 4 minus Line 5)' WHERE strTemplateItemId = 'MF-360-Summary-022'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'MF-360-Summary-023')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (40, N'MF-360-Summary-023', N'MF-360', 14, N'IN', N'Section 4:    Calculation of Total Amount Due', 7, 23, N'7. Gallons of gasoline sold to taxable marina', N'0', N'0', 1, NULL, N'Summary', 36, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '7. Gallons of gasoline sold to taxable marina' WHERE strTemplateItemId = 'MF-360-Summary-023'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'MF-360-Detail-001')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (NULL, N'MF-360-Detail-001', N'MF-360', 14, N'IN', N'Section A: Receipts', 1, 1, N'1. Gallons received, gasoline tax or inspection fee paid', N'1A', NULL, 0, NULL, N'Details', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '1. Gallons received, gasoline tax or inspection fee paid' WHERE strTemplateItemId = 'MF-360-Detail-001'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'MF-360-Detail-002')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (NULL, N'MF-360-Detail-002', N'MF-360', 14, N'IN', N'Section A: Receipts', 2, 2, N'2. Gallons received from licensed distributors or oil inspection distributors, tax unpaid', N'2', NULL, 0, NULL, N'Details', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '2. Gallons received from licensed distributors or oil inspection distributors, tax unpaid' WHERE strTemplateItemId = 'MF-360-Detail-002'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'MF-360-Detail-003')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
				VALUES (NULL, N'MF-360-Detail-003', N'MF-360', 14, N'IN', N'Section A: Receipts', 3, 3, N'3. Gallons of non-taxable fuel received and sold or used for a taxable purpose', N'2K', NULL, 0, NULL, N'Details', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '3. Gallons of non-taxable fuel received and sold or used for a taxable purpose' WHERE strTemplateItemId = 'MF-360-Detail-003'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'MF-360-Detail-005')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (NULL, N'MF-360-Detail-005', N'MF-360', 14, N'IN', N'Section A: Receipts', 4, 4, N'4. Gallons received from licensed distributors on exchange agreements, tax unpaid', N'2X', NULL, 0, NULL, N'Details', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '4. Gallons received from licensed distributors on exchange agreements, tax unpaid' WHERE strTemplateItemId = 'MF-360-Detail-005'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'MF-360-Detail-006')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (NULL, N'MF-360-Detail-006', N'MF-360', 14, N'IN', N'Section A: Receipts', 5, 5, N'5. Gallons imported directly to customer', N'3', NULL, 0, NULL, N'Details', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '5. Gallons imported directly to customer' WHERE strTemplateItemId = 'MF-360-Detail-006'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'MF-360-Detail-007')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (NULL, N'MF-360-Detail-007', N'MF-360', 14, N'IN', N'Section A: Receipts', 6, 6, N'6. Gallons imported into own storage', N'4', NULL, 0, NULL, N'Details', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '6. Gallons imported into own storage' WHERE strTemplateItemId = 'MF-360-Detail-007'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'MF-360-Detail-008')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
				VALUES (NULL, N'MF-360-Detail-008', N'MF-360', 14, N'IN', N'Section A: Receipts', 7, 7, N'7. Diversions into Indiana', N'11', NULL, 0, NULL, N'Details', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '7. Diversions into Indiana' WHERE strTemplateItemId = 'MF-360-Detail-008'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'MF-360-Detail-009')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (NULL, N'MF-360-Detail-009', N'MF-360', 14, N'IN', N'Section A: Receipts', 8, 8, N'8. Total receipts - add Lines 1-7, carry total (Column D) to Section 2, Line 1 on front', N'1A,2,2K,2X,3,4', NULL, 0, NULL, N'Details', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '8. Total receipts - add Lines 1-7, carry total (Column D) to Section 2, Line 1 on front' WHERE strTemplateItemId = 'MF-360-Detail-009'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'MF-360-Detail-010')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (NULL, N'MF-360-Detail-010', N'MF-360', 14, N'IN', N'Section A: Receipts', 9, 9, N'9. Total Receipts - add Lines 1-7, carry total (Column D) to Section 3, Line 1 on front', N'1A,2,2K,2X,3,4', NULL, 0, NULL, N'Details', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '9. Total Receipts - add Lines 1-7, carry total (Column D) to Section 3, Line 1 on front' WHERE strTemplateItemId = 'MF-360-Detail-010'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'MF-360-Detail-011')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (NULL, N'MF-360-Detail-011', N'MF-360', 14, N'IN', N'Section B: Disbursement', 1, 10, N'1. Gallons delivered, tax collected', N'5', NULL, 0, NULL, N'Details', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '1. Gallons delivered, tax collected' WHERE strTemplateItemId = 'MF-360-Detail-011'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'MF-360-Detail-012')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (NULL, N'MF-360-Detail-012', N'MF-360', 14, N'IN', N'Section B: Disbursement', 2, 11, N'2. Diversion out of Indiana', N'11', NULL, 0, NULL, N'Details', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '2. Diversion out of Indiana' WHERE strTemplateItemId = 'MF-360-Detail-012'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'MF-360-Detail-013')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (NULL, N'MF-360-Detail-013', N'MF-360', 14, N'IN', N'Section B: Disbursement', 3, 12, N'3. Gallons sold to licensed distributors, tax not collected', N'6D', NULL, 0, NULL, N'Details', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '3. Gallons sold to licensed distributors, tax not collected' WHERE strTemplateItemId = 'MF-360-Detail-013'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'MF-360-Detail-014')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId])
			VALUES (NULL, N'MF-360-Detail-014', N'MF-360', 14, N'IN', N'Section B: Disbursement', 4, 13, N'4. Gallons disbursed on exchange', N'6X', NULL, 0, NULL, N'Details', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '4. Gallons disbursed on exchange' WHERE strTemplateItemId = 'MF-360-Detail-014'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'MF-360-Detail-015')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (NULL, N'MF-360-Detail-015', N'MF-360', 14, N'IN', N'Section B: Disbursement', 5, 14, N'5. Gallons exported (must be filed in duplicate)', N'7', NULL, 0, NULL, N'Details', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '5. Gallons exported (must be filed in duplicate)' WHERE strTemplateItemId = 'MF-360-Detail-015'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'MF-360-Detail-016')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (NULL, N'MF-360-Detail-016', N'MF-360', 14, N'IN', N'Section B: Disbursement', 6, 15, N'6. Gallons delivered to U.S. Government - tax exempt', N'8', NULL, 0, NULL, N'Details', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '6. Gallons delivered to U.S. Government - tax exempt' WHERE strTemplateItemId = 'MF-360-Detail-016'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'MF-360-Detail-017')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (NULL, N'MF-360-Detail-017', N'MF-360', 14, N'IN', N'Section B: Disbursement', 7, 16, N'7 Gallons delivered to licensed marina fuel dealers', N'10A', NULL, 0, NULL, N'Details', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '7 Gallons delivered to licensed marina fuel dealers' WHERE strTemplateItemId = 'MF-360-Detail-017'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'MF-360-Detail-018')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (NULL, N'MF-360-Detail-018', N'MF-360', 14, N'IN', N'Section B: Disbursement', 8, 17, N'8. Gallons delivered to licensed aviation fuel dealers', N'10B', NULL, 0, NULL, N'Details', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '8. Gallons delivered to licensed aviation fuel dealers' WHERE strTemplateItemId = 'MF-360-Detail-018'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'MF-360-Summary-024')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (40, N'MF-360-Summary-024', N'MF-360', 14, N'IN', N'Section B: Disbursement', 9, 18, N'9. Miscelleaneous deduction - theft/loss', N'E-1', N'0', 1, NULL, N'Details', 39, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '9. Miscelleaneous deduction - theft/loss' WHERE strTemplateItemId = 'MF-360-Summary-024'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'MF-360-Summary-025')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (40, N'MF-360-Summary-025', N'MF-360', 14, N'IN', N'Section B: Disbursement', 10, 19, N'9a. Miscellaneous deduction - off road, other', N'E-1', N'2', 1, NULL, N'Details', 40, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '9a. Miscellaneous deduction - off road, other' WHERE strTemplateItemId = 'MF-360-Summary-025'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'MF-360-Detail-019')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (NULL, N'MF-360-Detail-019', N'MF-360', 14, N'IN', N'Section B: Disbursement', 11, 20, N'10. Total non-taxable disbursements - add Lines 2-9a, carry total to Section 2, line 2 on front.', N'11,6D,6X,7,8,10A,10B', NULL, 0, NULL, N'Details', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '10. Total non-taxable disbursements - add Lines 2-9a, carry total to Section 2, line 2 on front.' WHERE strTemplateItemId = 'MF-360-Detail-019'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'MF-360-Detail-020')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (NULL, N'MF-360-Detail-020', N'MF-360', 14, N'IN', N'Section B: Disbursement', 12, 21, N'11. Total non-taxable disbursements - add Lines 2-6, carry total to Section 3, line 2 on front', N'11,6D,6X,7,8', NULL, 0, NULL, N'Details', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '11. Total non-taxable disbursements - add Lines 2-6, carry total to Section 3, line 2 on front' WHERE strTemplateItemId = 'MF-360-Detail-020'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'MF-360-LicenseNumber')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (40, N'MF-360-LicenseNumber', N'MF-360', 14, N'IN', N'HEADER', 0, 0, N'License Number', NULL, N'0113334907', 1, NULL, N'HEADER', 5, 12)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = 'License Number' WHERE strTemplateItemId = 'MF-360-LicenseNumber'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'MF-360-Header-01')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId])
			VALUES (40, N'MF-360-Header-01', N'MF-360', 14, N'IN', N'HEADER', 0, 0, N'FilingType - Gasoline', NULL, N'1', 1, NULL, N'HEADER', 6, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = 'FilingType - Gasoline' WHERE strTemplateItemId = 'MF-360-Header-01'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'MF-360-Header-02')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (40, N'MF-360-Header-02', N'MF-360', 14, N'IN', N'HEADER', 0, 0, N'FilingType - Oil Inspection', NULL, N'1', 1, NULL, N'HEADER', 7, 2)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = 'FilingType - Oil Inspection' WHERE strTemplateItemId = 'MF-360-Header-02'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'MF-360-Header-03')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (40, N'MF-360-Header-03', N'MF-360', 14, N'IN', N'HEADER', 0, 0, N'FilingType - Gasohol Blender', NULL, N'1', 1, NULL, N'HEADER', 8, 1)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = 'FilingType - Gasohol Blender' WHERE strTemplateItemId = 'MF-360-Header-03'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'MF-360-LicenseHolderName')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
				VALUES (40, N'MF-360-LicenseHolderName', N'MF-360', 14, N'IN', N'HEADER', 0, 0, N'Name of License Holder', NULL, N'TP Name', 0, NULL, N'HEADER', 1, 2)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = 'Name of License Holder' WHERE strTemplateItemId = 'MF-360-LicenseHolderName'
		END

-- SF900

--SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'License Holder Name')
--IF (@TemplateId IS NULL)
--		BEGIN
--			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
--			VALUES (40, N'License Holder Name', N'MF-360', 14, N'IN', N'HEADER', 0, 0, N'Name of License Holder', NULL, N'TP Name', 0, NULL, N'HEADER', 1, 2)
--		END
--	ELSE
--		BEGIN
--			UPDATE tblTFTaxReportTemplate SET strDescription = 'Name of License Holder' WHERE strTemplateItemId = 'License Holder Name'
--		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'SF-900-FilingType-001')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (NULL, 'SF-900-FilingType-001', N'SF-900', 14, N'IN', N'1', 0, 0, N'Filing Type', N'', NULL, 0, NULL, N'Filing Type', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = 'Filing Type' WHERE strTemplateItemId = 'SF-900-FilingType-001'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'SF-900-Summary-001')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (NULL, N'SF-900-Summary-001', N'SF-900', 14, N'IN', N'Section 2: Computation of Tax', 1, 1, N'1. Total Receipts (From Section A, Line 5 on back of return)', N'1,2E,2K,3', NULL, 0, NULL, N'Summary', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '1. Total Receipts (From Section A, Line 5 on back of return)' WHERE strTemplateItemId = 'SF-900-Summary-001'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'SF-900-Summary-002')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
				VALUES (NULL, N'SF-900-Summary-002', N'SF-900', 14, N'IN', N'Section 2: Computation of Tax', 2, 2, N'2. Total Non-Taxable Disbursements (From Section B, Line 11 on back of return)', N'6,6X,7,7A,7B,8,10', NULL, 0, NULL, N'Summary', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '2. Total Non-Taxable Disbursements (From Section B, Line 11 on back of return)' WHERE strTemplateItemId = 'SF-900-Summary-002'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'SF-900-Summary-003')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
				VALUES (NULL, N'SF-900-Summary-003', N'SF-900', 14, N'IN', N'Section 2: Computation of Tax', 3, 3, N'3. Taxable Gallons Sold or Used (From Section B, Line 3, on back of return)', N'8,9', NULL, 0, NULL, N'Summary', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '3. Taxable Gallons Sold or Used (From Section B, Line 3, on back of return)' WHERE strTemplateItemId = 'SF-900-Summary-003'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'SF-900-Summary-004')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
				VALUES (NULL, N'SF-900-Summary-004', N'SF-900', 14, N'IN', N'Section 2: Computation of Tax', 4, 4, N'4.  Gallons Received Tax Paid (From Section A, Line 1, on back of return)', N'1', NULL, 0, NULL, N'Summary', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '4.  Gallons Received Tax Paid (From Section A, Line 1, on back of return)' WHERE strTemplateItemId = 'SF-900-Summary-004'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'SF-900-Summary-005')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
				VALUES (NULL, N'SF-900-Summary-005', N'SF-900', 14, N'IN', N'Section 2: Computation of Tax', 5, 5, N'5. Billed Taxable Gallons (Line 3 minus Line 4)', N'3,4', NULL, 0, NULL, N'Summary', NULL, 6)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '5. Billed Taxable Gallons (Line 3 minus Line 4)' WHERE strTemplateItemId = 'SF-900-Summary-005'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'SF-900-Summary-006')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
				VALUES (59, N'SF-900-Summary-006', N'SF-900', 14, N'IN', N'Section 2: Computation of Tax', 6, 6, N'6. Tax Due (Multiply Line 5 by $0.16)', N'5', N'0.16', 1, NULL, N'Summary', 50, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '6. Tax Due (Multiply Line 5 by $0.16)' WHERE strTemplateItemId = 'SF-900-Summary-006'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'SF-900-Summary-007')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
				VALUES (59, N'SF-900-Summary-007', N'SF-900', 14, N'IN', N'Section 2: Computation of Tax', 7, 7, N'7. Amount of Tax Uncollectible from Eligible Purchasers - Complete Schedule 10E', N'0', N'1', 1, NULL, N'Summary', 60, 7)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '7. Amount of Tax Uncollectible from Eligible Purchasers - Complete Schedule 10E' WHERE strTemplateItemId = 'SF-900-Summary-007'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'SF-900-Summary-008')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
				VALUES (NULL, N'SF-900-Summary-008', N'SF-900', 14, N'IN', N'Section 2: Computation of Tax', 8, 8, N'8. Adjusted Tax Due (Line 6 minus Line 7)', N'6,7', NULL, 0, NULL, N'Summary', NULL, 1)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '8. Adjusted Tax Due (Line 6 minus Line 7)' WHERE strTemplateItemId = 'SF-900-Summary-008'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'SF-900-Summary-009')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
				VALUES (59, N'SF-900-Summary-009', N'SF-900', 14, N'IN', N'Section 2: Computation of Tax', 9, 9, N'9. Collection Allowance (Multiply Line 8 by 0.016). If return filed or tax paid after due date enter zero (0)', N'8', N'0.016', 1, 'by', N'Summary', 70, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '9. Collection Allowance (Multiply Line 8 by 0.016). If return filed or tax paid after due date enter zero (0)' WHERE strTemplateItemId = 'SF-900-Summary-009'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'SF-900-Summary-010')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
				VALUES (59, N'SF-900-Summary-010', N'SF-900', 14, N'IN', N'Section 2: Computation of Tax', 10, 10, N'10. Adjustment - Complete Schedule E-1 (Dollar amount only)', N'0', N'3', 1, NULL, N'Summary', 80, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '10. Adjustment - Complete Schedule E-1 (Dollar amount only)' WHERE strTemplateItemId = 'SF-900-Summary-010'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'SF-900-Summary-011')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
				VALUES (NULL, N'SF-900-Summary-011', N'SF-900', 14, N'IN', N'Section 2: Computation of Tax', 11, 11, N'11. Total special fuel tax due (Line 8 minus Line 9 plus or minus Line 10)', N'8,9,10', NULL, 0, NULL,N'Summary', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '11. Total special fuel tax due (Line 8 minus Line 9 plus or minus Line 10)' WHERE strTemplateItemId = 'SF-900-Summary-011'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'SF-900-Summary-012')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
				VALUES (NULL, N'SF-900-Summary-012', N'SF-900', 14, N'IN', N'Section 3:    Calculation of Oil Inspection Fees Due', 1, 12, N'1. Total billed gallons (From Section 2, Line 5)', N'3,4', NULL, 0, NULL, N'Summary', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '1. Total billed gallons (From Section 2, Line 5)' WHERE strTemplateItemId = 'SF-900-Summary-012'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'SF-900-Summary-013')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
				VALUES (59, N'SF-900-Summary-013', N'SF-900', 14, N'IN', N'Section 3:    Calculation of Oil Inspection Fees Due', 2, 13, N'2. Oil inspection fees due (Multiply Line 1 by $0.01)', N'12', N'0.01', 1, NULL, N'Summary', 90, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '2. Oil inspection fees due (Multiply Line 1 by $0.01)' WHERE strTemplateItemId = 'SF-900-Summary-013'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'SF-900-Summary-014')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
				VALUES (59, N'SF-900-Summary-014', N'SF-900', 14, N'IN', N'Section 3:    Calculation of Oil Inspection Fees Due', 3, 14, N'3. Adjustments (Schedule E-1 must be attached and is subject to Department approval)', N'0', N'4', 1, NULL, N'Summary', 100, 5)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '3. Adjustments (Schedule E-1 must be attached and is subject to Department approval)' WHERE strTemplateItemId = 'SF-900-Summary-014'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'SF-900-Summary-015')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
				VALUES (NULL, N'SF-900-Summary-015', N'SF-900', 14, N'IN', N'Section 3:    Calculation of Oil Inspection Fees Due', 4, 15, N'4. Total oil inspection fees due (Line 2 plus or minus Line 3)', N'13,14', NULL, 0, NULL, N'Summary', NULL, 2)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '4. Total oil inspection fees due (Line 2 plus or minus Line 3)' WHERE strTemplateItemId = 'SF-900-Summary-015'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'SF-900-Summary-016')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
				VALUES (NULL, N'SF-900-Summary-016', N'SF-900', 14, N'IN', N'Section 4: Calculation of Total Amount Due', 1, 16, N'1. Total amount due (Section 2, Line 11 plus Section 3, Line 4)', N'11,15', NULL, 0, NULL, N'Summary', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '1. Total amount due (Section 2, Line 11 plus Section 3, Line 4)' WHERE strTemplateItemId = 'SF-900-Summary-016'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'SF-900-Summary-017')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
				VALUES (59, N'SF-900-Summary-017', N'SF-900', 14, N'IN', N'Section 4: Calculation of Total Amount Due', 2, 17, N'2. Penalty (Penalty must be added if report is filed after the due date. 10% of tax due or $5.00, whichever is greater. Five dollars ($5.00) is due on a late report showing no tax due.)', N'0', N'5', 1, NULL, N'Summary', 110, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '2. Penalty (Penalty must be added if report is filed after the due date. 10% of tax due or $5.00, whichever is greater. Five dollars ($5.00) is due on a late report showing no tax due.)' WHERE strTemplateItemId = 'SF-900-Summary-017'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'SF-900-Summary-018')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
				VALUES (59, N'SF-900-Summary-018', N'SF-900', 14, N'IN', N'Section 4: Calculation of Total Amount Due', 3, 18, N'3. Interest (Interest must be added if report is filed after the due date. Contact the Department for daily interest rates.)', N'0', N'0', 1, NULL, N'Summary', 120, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '3. Interest (Interest must be added if report is filed after the due date. Contact the Department for daily interest rates.)' WHERE strTemplateItemId = 'SF-900-Summary-018'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'SF-900-Summary-019')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
				VALUES (NULL, N'SF-900-Summary-019', N'SF-900', 14, N'IN', N'Section 4: Calculation of Total Amount Due', 4, 19, N'4. Net tax due (Line 1 plus Line 2 plus Line 3)', N'16,17,18', NULL, 0, NULL, N'Summary', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '4. Net tax due (Line 1 plus Line 2 plus Line 3)' WHERE strTemplateItemId = 'SF-900-Summary-019'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'SF-900-Summary-020')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
				VALUES (59, N'SF-900-Summary-020', N'SF-900', 14, N'IN', N'Section 4: Calculation of Total Amount Due', 5, 20, N'5. Payment(s)', N'0', N'0', 1, NULL, N'Summary', 130, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '5. Payment(s)' WHERE strTemplateItemId = 'SF-900-Summary-020'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'SF-900-Summary-021')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
				VALUES (NULL, N'SF-900-Summary-021', N'SF-900', 14, N'IN', N'Section 4: Calculation of Total Amount Due', 6, 21, N'6. Balance due (Line 4 minus Line 5)', N'19,20', NULL, 0, NULL, N'Summary', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '6. Balance due (Line 4 minus Line 5)' WHERE strTemplateItemId = 'SF-900-Summary-021'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'SF-900-Summary-022')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
				VALUES (NULL, N'SF-900-Summary-022', N'SF-900', 14, N'IN', N'Section A: Receipts', 1, 1, N'Section A:    Receipts', N'0', NULL, 0, NULL, N'Details', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = 'Section A:    Receipts' WHERE strTemplateItemId = 'SF-900-Summary-022'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'SF-900-Summary-023')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
				VALUES (NULL, N'SF-900-Summary-023', N'SF-900', 14, N'IN', N'Section A: Receipts', 2, 2, N'1. Gallons Received Tax Paid (Carry forward to Section 2, Line 4 on front of return)', N'1', NULL, 0, NULL, N'Details', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '1. Gallons Received Tax Paid (Carry forward to Section 2, Line 4 on front of return)' WHERE strTemplateItemId = 'SF-900-Summary-023'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'SF-900-Summary-024')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
				VALUES (NULL, N'SF-900-Summary-024', N'SF-900', 14, N'IN', N'Section A: Receipts', 3, 3, N'2. Gallons Received for Export (To be completed only by licensed exporters)', N'2E', NULL, 0, NULL, N'Details', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '2. Gallons Received for Export (To be completed only by licensed exporters)' WHERE strTemplateItemId = 'SF-900-Summary-024'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'SF-900-Summary-025')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
				VALUES (NULL, N'SF-900-Summary-025', N'SF-900', 14, N'IN', N'Section A: Receipts', 4, 4, N'3. Gallons of Nontaxable Fuel Received and Sold or Used For a Taxable Purpose', N'2K', NULL, 0, NULL, N'Details', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '3. Gallons of Nontaxable Fuel Received and Sold or Used For a Taxable Purpose' WHERE strTemplateItemId = 'SF-900-Summary-025'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'SF-900-Summary-026')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
				VALUES (NULL, N'SF-900-Summary-026', N'SF-900', 14, N'IN', N'Section A: Receipts', 5, 5, N'4. Gallons Imported Via Truck, Barge, or Rail, Tax Unpaid', N'3', NULL, 0, NULL, N'Details', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '4. Gallons Imported Via Truck, Barge, or Rail, Tax Unpaid' WHERE strTemplateItemId = 'SF-900-Summary-026'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'SF-900-Summary-027')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
				VALUES (NULL, N'SF-900-Summary-027', N'SF-900', 14, N'IN', N'Section A: Receipts', 6, 6, N'5. Total Receipts (Add Lines 1 through 4, carry forward to Section 2, Line 1 on', N'1,2E,2K,3', NULL, 0, NULL, N'Details', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '5. Total Receipts (Add Lines 1 through 4, carry forward to Section 2, Line 1 on' WHERE strTemplateItemId = 'SF-900-Summary-027'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'SF-900-Summary-028')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
				VALUES (NULL, N'SF-900-Summary-028', N'SF-900', 14, N'IN', N'Section B: Disbursement', 1, 7, N'Section B:    Disbursements', N'0', NULL, 0, NULL, N'Details', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = 'Section B:    Disbursements' WHERE strTemplateItemId = 'SF-900-Summary-028'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'SF-900-Summary-029')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
				VALUES (NULL, N'SF-900-Summary-029', N'SF-900', 14, N'IN', N'Section B: Disbursement', 2, 8, N'1. Gallons Delivered Tax Collected and Gallons Blended or Dyed Fuel Used', N'5', NULL, 0, NULL, N'Details', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '1. Gallons Delivered Tax Collected and Gallons Blended or Dyed Fuel Used' WHERE strTemplateItemId = 'SF-900-Summary-029'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'SF-900-Summary-030')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
				VALUES (NULL, N'SF-900-Summary-030', N'SF-900', 14, N'IN', N'Section B: Disbursement', 3, 9, N'2. Diversions (Special fuel only)', N'11', NULL, 0, NULL, N'Details', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '2. Diversions (Special fuel only)' WHERE strTemplateItemId = 'SF-900-Summary-030'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'SF-900-Summary-031')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
				VALUES (NULL, N'SF-900-Summary-031', N'SF-900', 14, N'IN', N'Section B: Disbursement', 4, 10, N'3. Taxable Gallons Sold or Used (Carry forward to Section 2, Line 3 on front', N'8,9', NULL, 0, NULL, N'Details', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '3. Taxable Gallons Sold or Used (Carry forward to Section 2, Line 3 on front' WHERE strTemplateItemId = 'SF-900-Summary-031'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'SF-900-Summary-032')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
				VALUES (NULL, N'SF-900-Summary-032', N'SF-900', 14, N'IN', N'Section B: Disbursement', 5, 11, N'4. Gallons Delivered Via Rail, Pipeline, or Vessel to Licensed Suppliers, Tax Not Collected', N'6', NULL, 0, NULL, N'Details', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '4. Gallons Delivered Via Rail, Pipeline, or Vessel to Licensed Suppliers, Tax Not Collected' WHERE strTemplateItemId = 'SF-900-Summary-032'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'SF-900-Summary-033')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
				VALUES (NULL, N'SF-900-Summary-033', N'SF-900', 14, N'IN', N'Section B: Disbursement', 6, 12, N'5. Gallons Disbursed on Exchange for Other Suppliers or Permissive Suppliers', N'6X', NULL, 0, NULL, N'Details', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '5. Gallons Disbursed on Exchange for Other Suppliers or Permissive Suppliers' WHERE strTemplateItemId = 'SF-900-Summary-033'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'SF-900-Summary-034')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
				VALUES (NULL, N'SF-900-Summary-034', N'SF-900', 14, N'IN', N'Section B: Disbursement', 7, 13, N'6. Gallons Exported by License Holder', N'7', NULL, 0, NULL, N'Details', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '6. Gallons Exported by License Holder' WHERE strTemplateItemId = 'SF-900-Summary-034'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'SF-900-Summary-035')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
				VALUES (NULL, N'SF-900-Summary-035', N'SF-900', 14, N'IN', N'Section B: Disbursement', 8, 14, N'7. Gallons Sold to Unlicensed Exporters for Export', N'7A', NULL, 0, NULL, N'Details', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '7. Gallons Sold to Unlicensed Exporters for Export' WHERE strTemplateItemId = 'SF-900-Summary-035'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'SF-900-Summary-036')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId])
				VALUES (NULL, N'SF-900-Summary-036', N'SF-900', 14, N'IN', N'Section B: Disbursement', 9, 15, N'8. Gallons Sold to Licensed Exporters for Export', N'7B', NULL, 0, NULL, N'Details', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '8. Gallons Sold to Licensed Exporters for Export' WHERE strTemplateItemId = 'SF-900-Summary-036'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'SF-900-Summary-037')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
				VALUES (NULL, N'SF-900-Summary-037', N'SF-900', 14, N'IN', N'Section B: Disbursement', 10, 16, N'9. Gallons of Undyed Fuel Sold to the U.S. Government - Tax Exempt', N'8', NULL, 0, NULL, N'Details', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '9. Gallons of Undyed Fuel Sold to the U.S. Government - Tax Exempt' WHERE strTemplateItemId = 'SF-900-Summary-037'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'SF-900-Summary-038')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
				VALUES (NULL, N'SF-900-Summary-038', N'SF-900', 14, N'IN', N'Section B: Disbursement', 11, 17, N'10. Gallons Sold of Tax Exempt Dyed Fuel', N'10', NULL, 0, NULL, N'Details', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '10. Gallons Sold of Tax Exempt Dyed Fuel' WHERE strTemplateItemId = 'SF-900-Summary-038'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'SF-900-Summary-039')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
				VALUES (NULL, N'SF-900-Summary-039', N'SF-900', 14, N'IN', N'Section B: Disbursement', 12, 18, N'11. Total Non-Taxable Disbursements (Add Lines 4 through 10; carry forward to Section 2, Line 2 on front of return', N'6,6X,7,7A,7B,8,10', NULL, 0, NULL, N'Details', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '11. Total Non-Taxable Disbursements (Add Lines 4 through 10; carry forward to Section 2, Line 2 on front of return' WHERE strTemplateItemId = 'SF-900-Summary-039'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'SF-900-Header-01')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
				VALUES (59, N'SF-900-Header-01', N'SF-900', 14, N'IN', N'HEADER', 0, 0, N'Supplier', NULL, N'1', 0, NULL, N'HEADER', 3, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = 'Supplier' WHERE strTemplateItemId = 'SF-900-Header-01'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'SF-900-Header-02')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
				VALUES (59, N'SF-900-Header-02', N'SF-900', 14, N'IN', N'HEADER', 0, 0, N'Permissive Supplier', NULL, N'1', 0, NULL, N'HEADER', 4, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = 'Permissive Supplier' WHERE strTemplateItemId = 'SF-900-Header-02'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'SF-900-Header-03')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
				VALUES (59, N'SF-900-Header-03', N'SF-900', 14, N'IN', N'HEADER', 0, 0, N'Importer', NULL, N'1', 0, NULL, N'HEADER', 5, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = 'Importer' WHERE strTemplateItemId = 'SF-900-Header-03'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'SF-900-Header-04')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
				VALUES (59, N'SF-900-Header-04', N'SF-900', 14, N'IN', N'HEADER', 0, 0, N'Exporter', NULL, N'1', 0, NULL, N'HEADER', 6, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = 'Exporter' WHERE strTemplateItemId = 'SF-900-Header-04'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'SF-900-Header-05')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
				VALUES (59, N'SF-900-Header-05', N'SF-900', 14, N'IN', N'HEADER', 0, 0, N'Blender', NULL, N'1', 0, NULL, N'HEADER', 7, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = 'Blender' WHERE strTemplateItemId = 'SF-900-Header-05'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'SF-900-Header-06')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
				VALUES (59, N'SF-900-Header-06', N'SF-900', 14, N'IN', N'HEADER', 0, 0, N'Dyed Fuel User', NULL, N'1', 0, NULL, N'HEADER', 8, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = 'Dyed Fuel User' WHERE strTemplateItemId = 'SF-900-Header-06'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'SF-900-LicenseHolderName')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
				VALUES (59, N'SF-900-LicenseHolderName', N'SF-900', 14, N'IN', N'HEADER', 0, 0, N'Name of License Holder', NULL, N'Company 01', 0, NULL, N'HEADER', 1, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = 'Name of License Holder' WHERE strTemplateItemId = 'SF-900-LicenseHolderName'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'SF-900-LicenseNumber')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
				VALUES (59, N'SF-900-LicenseNumber', N'SF-900', 14, N'IN', N'HEADER', 0, 0, N'License Number', NULL, N'0113334907', 0, NULL, N'HEADER', 2, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = 'License Number' WHERE strTemplateItemId = 'SF-900-LicenseNumber'
		END

--GT-103

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'GT-103-Summary-001')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (NULL, N'GT-103-Summary-001', N'GT-103', 14, N'IN', N'Gasoline Use Tax', 1, 1, N'1. Total Gallons Sold for Period', N'2D,1R', NULL, 0, NULL, N'Summary', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '1. Total Gallons Sold for Period' WHERE strTemplateItemId = 'GT-103-Summary-001'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'GT-103-Summary-002')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (NULL, N'GT-103-Summary-002', N'GT-103', 14, N'IN', N'Gasoline Use Tax', 2, 2, N'2. Total Exempt Gallons Sold for Period', N'2D', NULL, 0, NULL, N'Summary', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '2. Total Exempt Gallons Sold for Period' WHERE strTemplateItemId = 'GT-103-Summary-002'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'GT-103-Summary-003')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (NULL, N'GT-103-Summary-003', N'GT-103', 14, N'IN', N'Gasoline Use Tax', 3, 3, N'3. Total Taxable Gallons Sold (Line 1 minus Line 2)', N'1,2', NULL, 0, NULL, N'Summary', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '3. Total Taxable Gallons Sold (Line 1 minus Line 2)' WHERE strTemplateItemId = 'GT-103-Summary-003'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'GT-103-Summary-004')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (45, N'GT-103-Summary-004', N'GT-103', 14, N'IN', N'Gasoline Use Tax', 4, 4, N'4. Gasoline Use Tax Due. (Line 3 multiplied by the current rate. See Departmental Notice #2', N'3', N'0.10', 0, NULL, N'Summary', 9, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '4. Gasoline Use Tax Due. (Line 3 multiplied by the current rate. See Departmental Notice #2' WHERE strTemplateItemId = 'GT-103-Summary-004'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'GT-103-Summary-005')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (45, N'GT-103-Summary-005', N'GT-103', 14, N'IN', N'Gasoline Use Tax', 5, 5, N'5. Collection Allowance. Do not calculate this allowance if your return and payment are late. Collection allowance rate is 1%', N'0', N'1', 1, NULL, N'Summary', 10, 9)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '5. Collection Allowance. Do not calculate this allowance if your return and payment are late. Collection allowance rate is 1%' WHERE strTemplateItemId = 'GT-103-Summary-005'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'GT-103-Summary-006')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (NULL, N'GT-103-Summary-006', N'GT-103', 14, N'IN', N'Gasoline Use Tax', 6, 6, N'6. Net Gasoline Use Tax Due. Subtotal of use tax and collection allowance. (Line 4 minus Line 5)', N'4,5', NULL, 0, NULL, N'Summary', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '6. Net Gasoline Use Tax Due. Subtotal of use tax and collection allowance. (Line 4 minus Line 5)' WHERE strTemplateItemId = 'GT-103-Summary-006'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'GT-103-Summary-007')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (45, N'GT-103-Summary-007', N'GT-103', 14, N'IN', N'Gasoline Use Tax', 7, 7, N'7. Penalty Due. If late, the penalty is 10% of the tax due on Line 6 or $5, whichever is greater.', N'6', N'5', 1, NULL, N'Summary', 20, 7)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '7. Penalty Due. If late, the penalty is 10% of the tax due on Line 6 or $5, whichever is greater.' WHERE strTemplateItemId = 'GT-103-Summary-007'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'GT-103-Summary-008')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (45, N'GT-103-Summary-008', N'GT-103', 14, N'IN', N'Gasoline Use Tax', 8, 8, N'8. Interest Due. If late, multiply Line 6 by the interest rate (see Departmental Notice #)', N'6', N'4', 1, NULL, N'Summary', 30, 3)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '8. Interest Due. If late, multiply Line 6 by the interest rate (see Departmental Notice #)' WHERE strTemplateItemId = 'GT-103-Summary-008'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'GT-103-Summary-009')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId])
			VALUES (45, N'GT-103-Summary-009', N'GT-103', 14, N'IN', N'Gasoline Use Tax', 9, 9, N'9. Electronic Funds Transfer Credit', N'0', N'3', 1, NULL, N'Summary', 40, 2)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '9. Electronic Funds Transfer Credit' WHERE strTemplateItemId = 'GT-103-Summary-009'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'GT-103-Summary-010')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (45, N'GT-103-Summary-010', N'GT-103', 14, N'IN', N'Gasoline Use Tax', 10, 10, N'10. Adjustments. If negative entry, use a negative sign. (You must provide an explanation and supporting documentation to the Fuel Tax section.)', N'0', N'01', 1, NULL, N'Summary', 50, 4)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '10. Adjustments. If negative entry, use a negative sign. (You must provide an explanation and supporting documentation to the Fuel Tax section.)' WHERE strTemplateItemId = 'GT-103-Summary-010'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'GT-103-Summary-011')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (NULL, N'GT-103-Summary-011', N'GT-103', 14, N'IN', N'Gasoline Use Tax', 11, 11, N'11. Total Amount Due. (Add Lines 6 through 8, subtract Line 9, add Line 10).', N'6,7,8', NULL, 0, NULL, N'Summary', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '11. Total Amount Due. (Add Lines 6 through 8, subtract Line 9, add Line 10).' WHERE strTemplateItemId = 'GT-103-Summary-011'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'GT-103-Detail-002')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (NULL, N'GT-103-Detail-002', N'GT-103', 14, N'IN', N'Receipts - Schedule 1', 1, 1, N'Gasoline', N'1R', NULL, 0, NULL, N'Details', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = 'Gasoline' WHERE strTemplateItemId = 'GT-103-Detail-002'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'GT-103-Detail-003')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (NULL, N'GT-103-Detail-003', N'GT-103', 14, N'IN', N'Receipts - Schedule 1', 2, 2, N'Gasohol', N'1R', NULL, 0, NULL, N'Details', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = 'Gasohol' WHERE strTemplateItemId = 'GT-103-Detail-003'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'GT-103-Detail-004')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (NULL, N'GT-103-Detail-004', N'GT-103', 14, N'IN', N'Receipts - Schedule 1', 3, 3, N'Total Gallons of Fuel Purchased', N'1R', NULL, 0, NULL, N'Details', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = 'Total Gallons of Fuel Purchased' WHERE strTemplateItemId = 'GT-103-Detail-004'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'GT-103-Detail-004')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (NULL, N'GT-103-Detail-004', N'GT-103', 14, N'IN', N'Receipts - Schedule 1', 3, 3, N'Total Gallons of Fuel Purchased', N'1R', NULL, 0, NULL, N'Details', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = 'Total Gallons of Fuel Purchased' WHERE strTemplateItemId = 'GT-103-Detail-004'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'GT-103-Detail-005')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (NULL, N'GT-103-Detail-005', N'GT-103', 14, N'IN', N'Disbursements - Schedule 2', 1, 4, N'Gasoline', N'2D', NULL, 0, NULL, N'Details', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = 'Gasoline' WHERE strTemplateItemId = 'GT-103-Detail-005'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'GT-103-Detail-006')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (NULL, N'GT-103-Detail-006', N'GT-103', 14, N'IN', N'Disbursements - Schedule 2', 2, 5, N'Gasohol', N'2D', NULL, 0, NULL, N'Details', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = 'Gasohol' WHERE strTemplateItemId = 'GT-103-Detail-006'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'GT-103-Detail-007')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (NULL, N'GT-103-Detail-007', N'GT-103', 14, N'IN', N'Disbursements - Schedule 2', 3, 6, N'Total Gallons of Fuel Sold', N'2D', NULL, 0, NULL, N'Details', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = 'Total Gallons of Fuel Sold' WHERE strTemplateItemId = 'GT-103-Detail-007'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'GT-103-TID')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (45, N'GT-103-TID', N'GT-103', 14, N'IN', N'HEADER', 0, 0, N'Taxpayer Identification Number', NULL, N'12', 1, NULL, N'HEADER', 5, 4)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = 'Taxpayer Identification Number' WHERE strTemplateItemId = 'GT-103-TID'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'GT-103-TaxPayerName')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (45, N'GT-103-TaxPayerName', N'GT-103', 14, N'IN', N'HEADER', 0, 0, N'Tax Payer Name', NULL, N'TPayer Name', 0, NULL, N'HEADER', 1, 4)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = 'Tax Payer Name' WHERE strTemplateItemId = 'GT-103-TaxPayerName'
		END

--SF-401
SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'SF-401-FilingType-001')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (NULL, N'SF-401-FilingType-001', N'SF-401', 14, N'IN', N'1', 0, 0, N'Filing Type', N'', NULL, 0, NULL, N'Filing Type', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = 'Filing Type' WHERE strTemplateItemId = 'SF-401-FilingType-001'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'SF-401-Summary-001')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (NULL, N'SF-401-Summary-001', N'SF-401', 14, N'IN', N'', 1, 1, N'1. Total gallons of fuel loaded from an Indiana terminal or bulk plant and delivered to another state.', N'1A', NULL, 0, NULL, N'Summary', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '1. Total gallons of fuel loaded from an Indiana terminal or bulk plant and delivered to another state.' WHERE strTemplateItemId = 'SF-401-Summary-001'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'SF-401-Summary-002')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (NULL, N'SF-401-Summary-002', N'SF-401', 14, N'IN', N'', 2, 2, N'2. Total gallons of fuel loaded from an out-of-state terminal or bulk plant and delivered into Indiana.', N'2A', NULL, 0, NULL, N'Summary', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '2. Total gallons of fuel loaded from an out-of-state terminal or bulk plant and delivered into Indiana.' WHERE strTemplateItemId = 'SF-401-Summary-002'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'SF-401-Summary-003')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (NULL, N'SF-401-Summary-003', N'SF-401', 14, N'IN', N'', 3, 3, N'3. Total gallons of fuel loaded from an Indiana terminal or bulk plant and delivered within Indiana.', N'3A', NULL, 0, NULL, N'Summary', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '3. Total gallons of fuel loaded from an Indiana terminal or bulk plant and delivered within Indiana.' WHERE strTemplateItemId = 'SF-401-Summary-003'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'SF-401-Summary-004')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (NULL, N'SF-401-Summary-004', N'SF-401', 14, N'IN', N'', 4, 4, N'4. Total gallons of fuel transported (Add lines 1, 2, and 3).', '1A,2A,3A', NULL, 0, NULL, N'Summary', NULL, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = '4. Total gallons of fuel transported (Add lines 1, 2, and 3).' WHERE strTemplateItemId = 'SF-401-Summary-004'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'SF-401-LicenseNumber')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (69, N'SF-401-LicenseNumber', N'SF-401', 14, N'IN', N'', 5, 5, N'License Number', NULL, NULL, 0, NULL, NULL, 10, 6)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = 'License Number' WHERE strTemplateItemId = 'SF-401-LicenseNumber'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'SF-401-MotorCarrier')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (69, N'SF-401-MotorCarrier', N'SF-401', 14, N'IN', N'', 6, 6, N'Motor Carrier / IFTA Number', NULL, NULL, 0, NULL, NULL, 20, 0)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = 'Motor Carrier / IFTA Number' WHERE strTemplateItemId = 'SF-401-MotorCarrier'
		END

--EDI
SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'EDI-ISA01')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (70, N'EDI-ISA01', N'EDI', 14, N'IN', N'EDI', NULL, 0, N'ISA01 - Authorization Information Qualifier', NULL, N'03', 0, NULL, N'Summary', 42, 4)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = 'ISA01 - Authorization Information Qualifier' WHERE strTemplateItemId = 'EDI-ISA01'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'EDI-ISA02')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (70, N'EDI-ISA02', N'EDI', 14, N'IN', N'EDI', NULL, 0, N'ISA02 - Authorization Information', NULL, N'1234567899', 0, NULL, N'Summary', 46, 4)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = 'ISA02 - Authorization Information' WHERE strTemplateItemId = 'EDI-ISA02'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'EDI-ISA03')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (70, N'EDI-ISA03', N'EDI', 14, N'IN', N'EDI', NULL, 0, N'ISA03 - Security Information Qualifier', NULL, N'01', 0, NULL, N'Summary', 48, 5)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = 'ISA03 - Security Information Qualifier' WHERE strTemplateItemId = 'EDI-ISA03'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'EDI-ISA04')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (70, N'EDI-ISA04', N'EDI', 14, N'IN', N'EDI', NULL, 0, N'ISA04 - Security Information', NULL, N'9987654321', 0, NULL, N'Summary', 50, 4)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = 'ISA04 - Security Information' WHERE strTemplateItemId = 'EDI-ISA04'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'EDI-ISA05')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (70, N'EDI-ISA05', N'EDI', 14, N'IN', N'EDI', 7, 23, N'ISA05 - Interchange ID Qualifier', NULL, N'32', 0, NULL, N'Summary', 55, 4)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = 'ISA07 - Interchange ID Qualifier' WHERE strTemplateItemId = 'EDI-ISA05'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'EDI-ISA06')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (70, N'EDI-ISA06', N'EDI', 14, N'IN', N'EDI', 7, 23, N'ISA06 - Interchange Sender ID', NULL, N'777776666', 0, NULL, N'Summary', 60, 7)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = 'ISA06 - Interchange Sender ID' WHERE strTemplateItemId = 'EDI-ISA06'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'EDI-ISA07')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (70, N'EDI-ISA07', N'EDI', 14, N'IN', N'EDI', 7, 23, N'ISA07 - Interchange ID Qualifier', NULL, N'01', 0, NULL, N'Summary', 65, 3)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = 'ISA07 - Interchange ID Qualifier' WHERE strTemplateItemId = 'EDI-ISA07'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'EDI-ISA08')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (70, N'EDI-ISA08', N'EDI', 14, N'IN', N'EDI', 7, 23, N'ISA08 - Interchange Receiver ID', NULL, N'824799308', 0, NULL, N'Summary', 70, 3)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = 'ISA08 - Interchange Receiver ID' WHERE strTemplateItemId = 'EDI-ISA08'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'EDI-ISA11')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (70, N'EDI-ISA11', N'EDI', 14, N'IN', N'EDI', 7, 23, N'ISA11 - Repetition Separator', NULL, N'|', 0, NULL, N'Summary', 75, 4)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = 'ISA11 - Repetition Separator' WHERE strTemplateItemId = 'EDI-ISA11'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'EDI-ISA12')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (70, N'EDI-ISA12', N'EDI', 14, N'IN', N'EDI', 7, 23, N'ISA12 - Interchange Control Version Number', NULL, N'00403', 0, NULL, N'Summary', 80, 2)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = 'ISA12 - Interchange Control Version Number' WHERE strTemplateItemId = 'EDI-ISA12'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'EDI-ISA13')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (70, N'EDI-ISA13', N'EDI', 14, N'IN', N'EDI', 7, 23, N'ISA13 - Interchange Control Number (for next transmission)', NULL, N'1187', 0, NULL, N'Summary', 85, 2)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = 'ISA13 - Interchange Control Number (for next transmission)' WHERE strTemplateItemId = 'EDI-ISA13'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'EDI-ISA14')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (70, N'EDI-ISA14', N'EDI', 14, N'IN', N'EDI', 7, 23, N'ISA14 - Acknowledgement Requested', NULL, N'0', 0, NULL, N'Summary', 90, 4)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = 'ISA14 - Acknowledgement Requested' WHERE strTemplateItemId = 'EDI-ISA14'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'EDI-ISA15')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (70, N'EDI-ISA15', N'EDI', 14, N'IN', N'EDI', 7, 23, N'ISA15 - Usage Indicator', NULL, N'T', 0, NULL, N'Summary', 95, 2)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = 'ISA15 - Usage Indicator' WHERE strTemplateItemId = 'EDI-ISA15'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'EDI-ISA16')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId])
			VALUES (70, N'EDI-ISA16', N'EDI', 14, N'IN', N'EDI', 7, 23, N'ISA16 - Component Sub-element Separator', NULL, N'^', 0, NULL, N'Summary', 100, 4)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = 'ISA16 - Component Sub-element Separator' WHERE strTemplateItemId = 'EDI-ISA16'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'EDI-GS01')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (70, N'EDI-GS01', N'EDI', 14, N'IN', N'EDI', 7, 23, N'GS01 - Functional Identifier Code', NULL, N'TF', 0, NULL, N'Summary', 105, 2)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = 'GS01 - Functional Identifier Code' WHERE strTemplateItemId = 'EDI-GS01'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'EDI-GS02')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (70, N'EDI-GS02', N'EDI', 14, N'IN', N'EDI', 7, 23, N'GS02 - Application Sender''s Code', NULL, NULL, 0, NULL, N'Summary', 110, 2)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = 'GS02 - Application Sender''s Code' WHERE strTemplateItemId = 'EDI-GS02'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'EDI-GS03')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (70, N'EDI-GS03', N'EDI', 14, N'IN', N'EDI', 7, 23, N'GS03 - Receiver''s Code', NULL, N'824799308050', 0, NULL, N'Summary', 115, 2)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = 'GS03 - Receiver''s Code' WHERE strTemplateItemId = 'EDI-GS03'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'EDI-GS06')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (70, N'EDI-GS06', N'EDI', 14, N'IN', N'EDI', 7, 23, N'GS06 - Group Control Number (for next transmission)', NULL, N'1202', 0, NULL, N'Summary', 120, 3)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = 'GS06 - Group Control Number (for next transmission)' WHERE strTemplateItemId = 'EDI-GS06'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'EDI-GS07')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (70, N'EDI-GS07', N'EDI', 14, N'IN', N'EDI', 7, 23, N'GS07 - Responsible Agency Code', NULL, N'X', 0, NULL, N'Summary', 125, 2)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = 'GS07 - Responsible Agency Code' WHERE strTemplateItemId = 'EDI-GS07'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'EDI-GS08')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (70, N'EDI-GS08', N'EDI', 14, N'IN', N'EDI', 7, 23, N'GS08 - Version/Release/Industry ID Code', NULL, N'004030', 0, NULL, N'Summary', 130, 2)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = 'GS08 - Version/Release/Industry ID Code' WHERE strTemplateItemId = 'EDI-GS08'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'EDI-ST01')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId])
			VALUES (70, N'EDI-ST01', N'EDI', 14, N'IN', N'EDI', 7, 23, N'ST01 - Transaction Set Code', NULL, N'813', 0, NULL, N'Summary', 135, 3)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = 'ST01 - Transaction Set Code' WHERE strTemplateItemId = 'EDI-ST01'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'EDI-ST02')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (70, N'EDI-ST02', N'EDI', 14, N'IN', N'EDI', 7, 23, N'ST02 - Transaction Set Control Number (for next transmission)', NULL, N'3211', 0, NULL, N'Summary', 137, 3)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = 'ST02 - Transaction Set Control Number (for next transmission)' WHERE strTemplateItemId = 'EDI-ST02'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'EDI-BTI13')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (70, N'EDI-BTI13', N'EDI', 14, N'IN', N'EDI', 7, 23, N'BTI13 - Transaction Set Purpose Code', NULL, N'00', 0, NULL, N'Summary', 140, 3)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = 'BTI13 - Transaction Set Purpose Code' WHERE strTemplateItemId = 'EDI-BTI13'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'EDI-BTI14')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (70, N'EDI-BTI14', N'EDI', 14, N'IN', N'EDI', 7, 23, N'BTI14 - Transaction Type Code', NULL, NULL, 0, NULL, N'Summary', 145, 2)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = 'BTI14 - Transaction Type Code' WHERE strTemplateItemId = 'EDI-BTI14'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'EDI-FilePath')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (70, N'EDI-FilePath', N'EDI', 14, N'IN', N'EDI', 7, 23, N'EDI File Path', NULL, N'C:\dir', 0, NULL, N'Summary', 155, 2)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = 'EDI File Path' WHERE strTemplateItemId = 'EDI-FilePath'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'EDI-FileName1st')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (70, N'EDI-FileName1st', N'EDI', 14, N'IN', N'EDI', 7, 23, N'EDI File Name - 1st part (TST or PRD)', NULL, N'T', 0, NULL, N'Summary', 160, 3)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = 'EDI File Name - 1st part (TST or PRD)' WHERE strTemplateItemId = 'EDI-FileName1st'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'EDI-FileName2nd')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (70, N'EDI-FileName2nd', N'EDI', 14, N'IN', N'EDI', 7, 23, N'EDI File Name - 2nd part (Tax Payer Code)', NULL, N'FREE', 0, NULL, N'Summary', 165, 4)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = 'EDI File Name - 2nd part (Tax Payer Code)' WHERE strTemplateItemId = 'EDI-FileName2nd'
		END

SET @TemplateId = (SELECT TOP 1 strTemplateItemId FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'EDI-FileName3rd')
IF (@TemplateId IS NULL)
		BEGIN
			INSERT [dbo].[tblTFTaxReportTemplate] ([intReportingComponentId], [strTemplateItemId], [strFormCode], [intTaxAuthorityId], [strTaxAuthority], [strReportSection], [intReportItemSequence], [intTemplateItemNumber], [strDescription], [strScheduleCode], [strConfiguration], [ysnDynamicConfiguration], [strLastIndexOf], [strSegment], [intConfigurationSequence], [intConcurrencyId]) 
			VALUES (70, N'EDI-FileName3rd', N'EDI', 14, N'IN', N'EDI', 7, 23, N'EDI File Name - 3rd part (Next Sequence Number)', NULL, N'2237', 0, NULL,N'Summary', 170, 24)
		END
	ELSE
		BEGIN
			UPDATE tblTFTaxReportTemplate SET strDescription = 'EDI File Name - 3rd part (Next Sequence Number)' WHERE strTemplateItemId = 'EDI-FileName3rd'
		END