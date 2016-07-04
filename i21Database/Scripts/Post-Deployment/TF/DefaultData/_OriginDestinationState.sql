GO
PRINT 'START TF tblTFOriginDestinationState'
GO

DECLARE @OriginDestinationStateId INT

SELECT TOP 1 @OriginDestinationStateId = intOriginDestinationStateId FROM tblTFOriginDestinationState
IF (@OriginDestinationStateId IS NULL)
	BEGIN

		INSERT [tblTFOriginDestinationState] ([strOriginDestinationState], [intConcurrencyId]) VALUES (N'AL', 0)
		INSERT [tblTFOriginDestinationState] ([strOriginDestinationState], [intConcurrencyId]) VALUES (N'AK', 0)
		INSERT [tblTFOriginDestinationState] ([strOriginDestinationState], [intConcurrencyId]) VALUES (N'AZ', 0)
		INSERT [tblTFOriginDestinationState] ([strOriginDestinationState], [intConcurrencyId]) VALUES (N'AR', 0)
		INSERT [tblTFOriginDestinationState] ([strOriginDestinationState], [intConcurrencyId]) VALUES (N'CA', 0)
		INSERT [tblTFOriginDestinationState] ([strOriginDestinationState], [intConcurrencyId]) VALUES (N'CO', 0)
		INSERT [tblTFOriginDestinationState] ([strOriginDestinationState], [intConcurrencyId]) VALUES (N'CT', 0)
		INSERT [tblTFOriginDestinationState] ([strOriginDestinationState], [intConcurrencyId]) VALUES (N'DE', 0)
		INSERT [tblTFOriginDestinationState] ([strOriginDestinationState], [intConcurrencyId]) VALUES (N'FL', 0)
		INSERT [tblTFOriginDestinationState] ([strOriginDestinationState], [intConcurrencyId]) VALUES (N'GA', 0)
		INSERT [tblTFOriginDestinationState] ([strOriginDestinationState], [intConcurrencyId]) VALUES (N'HI', 0)
		INSERT [tblTFOriginDestinationState] ([strOriginDestinationState], [intConcurrencyId]) VALUES (N'ID', 0)
		INSERT [tblTFOriginDestinationState] ([strOriginDestinationState], [intConcurrencyId]) VALUES (N'IL', 0)
		INSERT [tblTFOriginDestinationState] ([strOriginDestinationState], [intConcurrencyId]) VALUES (N'IN', 0)
		INSERT [tblTFOriginDestinationState] ([strOriginDestinationState], [intConcurrencyId]) VALUES (N'IA', 0)
		INSERT [tblTFOriginDestinationState] ([strOriginDestinationState], [intConcurrencyId]) VALUES (N'KS', 0)
		INSERT [tblTFOriginDestinationState] ([strOriginDestinationState], [intConcurrencyId]) VALUES (N'KY', 0)
		INSERT [tblTFOriginDestinationState] ([strOriginDestinationState], [intConcurrencyId]) VALUES (N'LA', 0)
		INSERT [tblTFOriginDestinationState] ([strOriginDestinationState], [intConcurrencyId]) VALUES (N'ME', 0)
		INSERT [tblTFOriginDestinationState] ([strOriginDestinationState], [intConcurrencyId]) VALUES (N'MD', 0)
		INSERT [tblTFOriginDestinationState] ([strOriginDestinationState], [intConcurrencyId]) VALUES (N'MA', 0)
		INSERT [tblTFOriginDestinationState] ([strOriginDestinationState], [intConcurrencyId]) VALUES (N'MI', 0)
		INSERT [tblTFOriginDestinationState] ([strOriginDestinationState], [intConcurrencyId]) VALUES (N'MN', 0)
		INSERT [tblTFOriginDestinationState] ([strOriginDestinationState], [intConcurrencyId]) VALUES (N'MS', 0)
		INSERT [tblTFOriginDestinationState] ([strOriginDestinationState], [intConcurrencyId]) VALUES (N'MO', 0)
		INSERT [tblTFOriginDestinationState] ([strOriginDestinationState], [intConcurrencyId]) VALUES (N'MT', 0)
		INSERT [tblTFOriginDestinationState] ([strOriginDestinationState], [intConcurrencyId]) VALUES (N'NE', 0)
		INSERT [tblTFOriginDestinationState] ([strOriginDestinationState], [intConcurrencyId]) VALUES (N'NV', 0)
		INSERT [tblTFOriginDestinationState] ([strOriginDestinationState], [intConcurrencyId]) VALUES (N'NH', 0)
		INSERT [tblTFOriginDestinationState] ([strOriginDestinationState], [intConcurrencyId]) VALUES (N'NJ', 0)
		INSERT [tblTFOriginDestinationState] ([strOriginDestinationState], [intConcurrencyId]) VALUES (N'NM', 0)
		INSERT [tblTFOriginDestinationState] ([strOriginDestinationState], [intConcurrencyId]) VALUES (N'NY', 0)
		INSERT [tblTFOriginDestinationState] ([strOriginDestinationState], [intConcurrencyId]) VALUES (N'NC', 0)
		INSERT [tblTFOriginDestinationState] ([strOriginDestinationState], [intConcurrencyId]) VALUES (N'ND', 0)
		INSERT [tblTFOriginDestinationState] ([strOriginDestinationState], [intConcurrencyId]) VALUES (N'OH', 0)
		INSERT [tblTFOriginDestinationState] ([strOriginDestinationState], [intConcurrencyId]) VALUES (N'OK', 0)
		INSERT [tblTFOriginDestinationState] ([strOriginDestinationState], [intConcurrencyId]) VALUES (N'OR', 0)
		INSERT [tblTFOriginDestinationState] ([strOriginDestinationState], [intConcurrencyId]) VALUES (N'PA', 0)
		INSERT [tblTFOriginDestinationState] ([strOriginDestinationState], [intConcurrencyId]) VALUES (N'RI', 0)
		INSERT [tblTFOriginDestinationState] ([strOriginDestinationState], [intConcurrencyId]) VALUES (N'SC', 0)
		INSERT [tblTFOriginDestinationState] ([strOriginDestinationState], [intConcurrencyId]) VALUES (N'SD', 0)
		INSERT [tblTFOriginDestinationState] ([strOriginDestinationState], [intConcurrencyId]) VALUES (N'TN', 0)
		INSERT [tblTFOriginDestinationState] ([strOriginDestinationState], [intConcurrencyId]) VALUES (N'TX', 0)
		INSERT [tblTFOriginDestinationState] ([strOriginDestinationState], [intConcurrencyId]) VALUES (N'UT', 0)
		INSERT [tblTFOriginDestinationState] ([strOriginDestinationState], [intConcurrencyId]) VALUES (N'VT', 0)
		INSERT [tblTFOriginDestinationState] ([strOriginDestinationState], [intConcurrencyId]) VALUES (N'VA', 0)
		INSERT [tblTFOriginDestinationState] ([strOriginDestinationState], [intConcurrencyId]) VALUES (N'WA', 0)
		INSERT [tblTFOriginDestinationState] ([strOriginDestinationState], [intConcurrencyId]) VALUES (N'WV', 0)
		INSERT [tblTFOriginDestinationState] ([strOriginDestinationState], [intConcurrencyId]) VALUES (N'WI', 0)
		INSERT [tblTFOriginDestinationState] ([strOriginDestinationState], [intConcurrencyId]) VALUES (N'WY', 0)

	END

GO
	PRINT 'END TF tblTFOriginDestinationState'
GO




