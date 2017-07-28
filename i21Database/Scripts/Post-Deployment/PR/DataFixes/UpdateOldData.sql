/***********************
* UPDATING OLD DATA
************************/

/*
* Employee Workers Compensation 
* 1. Change Rate Type from "Amount" to "Per Dollar"
* 2....
*/

IF EXISTS(SELECT * FROM sys.tables WHERE object_id = object_id('tblPRWorkersCompensation'))
BEGIN
	EXEC ('
	UPDATE tblPRWorkersCompensation 
		SET strCalculationType = ''Per Dollar''
	WHERE strCalculationType IS NULL OR strCalculationType = ''Amount''
	')
END