GO
	PRINT N'BEGIN INSERT DEFAULT COUNTRIES'
GO
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMFreightTerms WHERE strFreightTerm = N'Truck') 
	BEGIN 
		INSERT [dbo].tblSMFreightTerms ([strFreightTerm], [strFobPoint], [ysnActive], [intConcurrencyId], [strContractBasis], [strDescription]) 
		VALUES (N'Truck', N'Destination', 1 , 1, N'Truck', N'Truck') 
	END
	ELSE
	BEGIN
		UPDATE tblSMFreightTerms SET [strFobPoint] = N'Destination' WHERE strFreightTerm = N'Truck'
	END

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMFreightTerms where strFreightTerm = N'Deliver') 
	BEGIN 
		INSERT [dbo].tblSMFreightTerms ([strFreightTerm], [strFobPoint], [ysnActive], [intConcurrencyId], [strContractBasis], [strDescription]) 
		VALUES (N'Deliver', N'Destination', 1 , 1, N'Deliver', N'Deliver') 
	END
	ELSE
	BEGIN
		UPDATE tblSMFreightTerms SET [strFobPoint] = N'Destination' WHERE strFreightTerm = N'Deliver'
	END

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMFreightTerms where strFreightTerm = N'Pickup') 
	BEGIN 
		INSERT [dbo].tblSMFreightTerms ([strFreightTerm], [strFobPoint], [ysnActive], [intConcurrencyId], [strContractBasis], [strDescription]) 
		VALUES (N'Pickup', N'Origin', 1 , 1, N'Pickup', N'Pickup') 
	END
	ELSE
	BEGIN
		UPDATE tblSMFreightTerms SET [strFobPoint] = N'Origin' WHERE strFreightTerm = N'Pickup'
	END

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMFreightTerms where strFreightTerm = N'Dlvd') 
	BEGIN 
		INSERT [dbo].tblSMFreightTerms ([strFreightTerm], [strFobPoint], [ysnActive], [intConcurrencyId], [strContractBasis], [strDescription]) 
		VALUES (N'Dlvd', N'Origin', 1 , 1, N'Dlvd', N'Dlvd') 
	END
	ELSE
	BEGIN
		UPDATE tblSMFreightTerms SET [strFobPoint] = N'Origin' WHERE strFreightTerm = N'Dlvd'
	END

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMFreightTerms where strFreightTerm = N'Rail') 
	BEGIN 
		INSERT [dbo].tblSMFreightTerms ([strFreightTerm], [strFobPoint], [ysnActive], [intConcurrencyId], [strContractBasis], [strDescription]) 
		VALUES (N'Rail', N'Origin', 1 , 1, N'Rail', N'Rail') 
	END
	ELSE
	BEGIN
		UPDATE tblSMFreightTerms SET [strFobPoint] = N'Origin' WHERE strFreightTerm = N'Rail'
	END

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMFreightTerms where strFreightTerm = N'Barge') 
	BEGIN 
		INSERT [dbo].tblSMFreightTerms ([strFreightTerm], [strFobPoint], [ysnActive], [intConcurrencyId], [strContractBasis], [strDescription]) 
		VALUES (N'Barge', N'Origin', 1 , 1, N'Barge', N'Barge') 
	END
	ELSE
	BEGIN
		UPDATE tblSMFreightTerms SET [strFobPoint] = N'Origin' WHERE strFreightTerm = N'Barge'
	END

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMFreightTerms where strFreightTerm = N'Vessel') 
	BEGIN 
		INSERT [dbo].tblSMFreightTerms ([strFreightTerm], [strFobPoint], [ysnActive], [intConcurrencyId], [strContractBasis], [strDescription]) 
		VALUES (N'Vessel', N'Origin', 1 , 1, N'Vessel', N'Vessel') 
	END
	ELSE
	BEGIN
		UPDATE tblSMFreightTerms SET [strFobPoint] = N'Origin' WHERE strFreightTerm = N'Vessel'
	END

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMFreightTerms where strFreightTerm = N'FOB') 
	BEGIN 
		INSERT [dbo].tblSMFreightTerms ([strFreightTerm], [strFobPoint], [ysnActive], [intConcurrencyId], [strContractBasis], [strDescription]) 
		VALUES (N'FOB', N'Origin', 1 , 1, N'FOB', N'FOB') 
	END
	ELSE
	BEGIN
		UPDATE tblSMFreightTerms SET [strFobPoint] = N'Origin' WHERE strFreightTerm = N'FOB'
	END
GO
	PRINT N'END INSERT DEFAULT COUNTRIES'