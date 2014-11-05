CREATE PROCEDURE [testi21Database].[Fake data for simple COA]
AS
BEGIN
		-- Drop these views. It has dependencies with tblGLAccount table. Can't do fake table if these exists. 
		-- note: when tSQLt do the rollback, the views are rolled back as well. 
		DROP VIEW vyuAPBill
		DROP VIEW vyuAPBillBatch
		DROP VIEW vyuAPPayablesAgingSummary
		DROP VIEW vyuAPPaymentDetail
		DROP VIEW vyuAPVendor
		DROP VIEW vyuAPRecapTransaction

		-- Create the fake table		
		EXEC tSQLt.FakeTable 'dbo.tblGLAccountStructure';
		EXEC tSQLt.FakeTable 'dbo.tblGLAccountSegment';
		EXEC tSQLt.FakeTable 'dbo.tblGLAccount';
		EXEC tSQLt.FakeTable 'dbo.tblGLAccountSegmentMapping', @Identity = 1;
		
		-- Add fake data for Account Structure
		INSERT INTO tblGLAccountStructure (intAccountStructureId, strType, intStartingPosition, strMask) VALUES (90, 'Primary', 1, '0')
		INSERT INTO tblGLAccountStructure (intAccountStructureId, strType, intStartingPosition, strMask) VALUES (91, 'Divider', 0, '-')
		INSERT INTO tblGLAccountStructure (intAccountStructureId, strType, intStartingPosition, strMask) VALUES (92, 'Segment', 2, '0')

		-- Add fake data for Account Segment
		INSERT INTO tblGLAccountSegment (intAccountSegmentId, strCode, strDescription, intAccountStructureId) VALUES (1, '12040', 'INVENTORY WHEAT', 90)
		INSERT INTO tblGLAccountSegment (intAccountSegmentId, strCode, strDescription, intAccountStructureId) VALUES (2, '40100', 'COST OF GOODS WHEAT', 90)
		INSERT INTO tblGLAccountSegment (intAccountSegmentId, strCode, strDescription, intAccountStructureId) VALUES (3, '50110', 'PURCHASES WHEAT', 90)
		INSERT INTO tblGLAccountSegment (intAccountSegmentId, strCode, strDescription, intAccountStructureId) VALUES (100, '1000', '', 92)
		INSERT INTO tblGLAccountSegment (intAccountSegmentId, strCode, strDescription, intAccountStructureId) VALUES (101, '1001', 'NEW HAVEN GRAIN', 92)
		INSERT INTO tblGLAccountSegment (intAccountSegmentId, strCode, strDescription, intAccountStructureId) VALUES (102, '1002', 'BETTER HAVEN GRAIN', 92)

		-- Add fake data for GL Account
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (1000, 'INVENTORY WHEAT-', '12040-1000');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (2000, 'COST OF GOODS WHEAT-', '40100-1000');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (3000, 'PURCHASES WHEAT-', '50110-1000');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (1001, 'INVENTORY WHEAT-NEW HAVEN GRAIN', '12040-1001');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (2001, 'COST OF GOODS WHEAT-NEW HAVEN GRAIN', '40100-1001');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (3001, 'PURCHASES WHEAT-NEW HAVEN GRAIN', '50110-1001');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (1002, 'INVENTORY WHEAT-BETTER HAVEN GRAIN', '12040-1002');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (2002, 'COST OF GOODS WHEAT-BETTER HAVEN GRAIN', '40100-1002');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (3002, 'PURCHASES WHEAT-BETTER HAVEN GRAIN', '50110-1002');

		-- Add fake data for Segment Mapping
		-- INVENTORY WHEAT-'
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (1000, 1);
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (1000, 100);
		-- COST OF GOODS WHEAT-
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (2000, 2);
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (2000, 100);
		-- PURCHASES WHEAT-
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (3000, 3);
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (3000, 100);

		-- INVENTORY WHEAT-NEW HAVEN GRAIN
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (1001, 1);
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (1001, 101);
		-- COST OF GOODS WHEAT-NEW HAVEN GRAIN
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (2001, 2);
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (2001, 101);
		-- PURCHASES WHEAT-NEW HAVEN GRAIN
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (3001, 3);
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (3001, 101);	

		-- INVENTORY WHEAT-BETTER HAVEN GRAIN
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (1002, 1);
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (1002, 102);
		-- COST OF GOODS WHEAT-BETTER HAVEN GRAIN
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (2002, 2);
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (2002, 102);
		-- PURCHASES WHEAT-BETTER HAVEN GRAIN
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (3002, 3);
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (3002, 102);	

END 