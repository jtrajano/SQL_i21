GO
	SET IDENTITY_INSERT tblSMTransportationMode ON

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMTransportationMode WHERE strCode = 'J')
	BEGIN
		INSERT INTO tblSMTransportationMode([intTransportationModeId], [strCode], [strDescription])
		VALUES(1, 'J', 'Truck')
	END

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMTransportationMode WHERE strCode = 'R')
	BEGIN
		INSERT INTO tblSMTransportationMode([intTransportationModeId], [strCode], [strDescription])
		VALUES(2, 'R', 'Rail')
	END

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMTransportationMode WHERE strCode = 'B')
	BEGIN
		INSERT INTO tblSMTransportationMode([intTransportationModeId], [strCode], [strDescription])
		VALUES(3, 'B', 'Barge')
	END

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMTransportationMode WHERE strCode = 'S')
	BEGIN
		INSERT INTO tblSMTransportationMode([intTransportationModeId], [strCode], [strDescription])
		VALUES(4, 'S', 'Ship')
	END

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMTransportationMode WHERE strCode = 'PL')
	BEGIN
		INSERT INTO tblSMTransportationMode([intTransportationModeId], [strCode], [strDescription])
		VALUES(5, 'PL', 'Pipeline')
	END

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMTransportationMode WHERE strCode = 'GS')
	BEGIN
		INSERT INTO tblSMTransportationMode([intTransportationModeId], [strCode], [strDescription])
		VALUES(6, 'GS', 'Gas Station')
	END

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMTransportationMode WHERE strCode = 'BA')
	BEGIN
		INSERT INTO tblSMTransportationMode([intTransportationModeId], [strCode], [strDescription])
		VALUES(7, 'BA', 'Book Adjustment')
	END
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMTransportationMode WHERE strCode = 'ST')
	BEGIN
		INSERT INTO tblSMTransportationMode([intTransportationModeId], [strCode], [strDescription])
		VALUES(8, 'ST', 'Stationary Transfer')
	END

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMTransportationMode WHERE strCode = 'CE')
	BEGIN
		INSERT INTO tblSMTransportationMode([intTransportationModeId], [strCode], [strDescription])
		VALUES(9, 'CE', 'Summary Information')
	END

	SET IDENTITY_INSERT tblSMTransportationMode OFF
GO