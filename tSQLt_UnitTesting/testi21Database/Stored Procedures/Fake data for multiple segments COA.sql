CREATE PROCEDURE [testi21Database].[Fake data for multiple segments COA]
AS
BEGIN
		-- Drop these views. It has dependencies with tblGLAccount table. Can't do fake table if these exists. 
		-- note: when tSQLt do the rollback, the views are rolled back as well. 
		DROP VIEW vyuAPBill
		DROP VIEW vyuAPBillBatch
		DROP VIEW vyuAPPayablesAgingSummary
		DROP VIEW vyuAPPaymentDetail
		DROP VIEW vyuAPVendor

		-- Create the fake table		
		EXEC tSQLt.FakeTable 'dbo.tblGLAccountStructure';
		EXEC tSQLt.FakeTable 'dbo.tblGLAccountSegment';
		EXEC tSQLt.FakeTable 'dbo.tblGLAccount';
		EXEC tSQLt.FakeTable 'dbo.tblGLAccountSegmentMapping', @Identity = 1;
		
		-- Add fake data for Account Structure
		INSERT INTO tblGLAccountStructure (intAccountStructureId, strType, intStartingPosition, strMask) VALUES (90, 'Primary', 1, '0')
		INSERT INTO tblGLAccountStructure (intAccountStructureId, strType, intStartingPosition, strMask) VALUES (91, 'Divider', 0, '-')
		INSERT INTO tblGLAccountStructure (intAccountStructureId, strType, intStartingPosition, strMask) VALUES (92, 'Segment', 2, '0')
		INSERT INTO tblGLAccountStructure (intAccountStructureId, strType, intStartingPosition, strMask) VALUES (93, 'Segment', 3, '0')
		INSERT INTO tblGLAccountStructure (intAccountStructureId, strType, intStartingPosition, strMask) VALUES (94, 'Segment', 4, '0')

		-- Add fake data for Account Segment
		INSERT INTO tblGLAccountSegment (intAccountSegmentId, strCode, strDescription, intAccountStructureId) VALUES (1, '12040', 'INVENTORY WHEAT', 90)
		INSERT INTO tblGLAccountSegment (intAccountSegmentId, strCode, strDescription, intAccountStructureId) VALUES (2, '40100', 'SALES WHEAT', 90)
		INSERT INTO tblGLAccountSegment (intAccountSegmentId, strCode, strDescription, intAccountStructureId) VALUES (3, '50110', 'PURCHASES WHEAT', 90)
		INSERT INTO tblGLAccountSegment (intAccountSegmentId, strCode, strDescription, intAccountStructureId) VALUES (100, '1000', '', 92)
		INSERT INTO tblGLAccountSegment (intAccountSegmentId, strCode, strDescription, intAccountStructureId) VALUES (101, '1001', 'NEW HAVEN GRAIN', 92)		
		INSERT INTO tblGLAccountSegment (intAccountSegmentId, strCode, strDescription, intAccountStructureId) VALUES (500, 'ABC', 'ABCs', 93)
		INSERT INTO tblGLAccountSegment (intAccountSegmentId, strCode, strDescription, intAccountStructureId) VALUES (501, 'XYZ', 'XYZs', 93)		
		INSERT INTO tblGLAccountSegment (intAccountSegmentId, strCode, strDescription, intAccountStructureId) VALUES (8800, 'FOO', 'FOOS', 94)
		INSERT INTO tblGLAccountSegment (intAccountSegmentId, strCode, strDescription, intAccountStructureId) VALUES (8801, 'BAR', 'BARS', 94)

		-- Add fake data for GL Account
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (1000, 'INVENTORY WHEAT--ABCs-FOOs', '12040-1000-ABC-FOO');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (2000, 'SALES WHEAT--ABCs-FOOs', '40100-1000-ABC-FOO');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (3000, 'PURCHASES WHEAT--ABCs-FOOs', '50110-1000-ABC-FOO');
		
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (1001, 'INVENTORY WHEAT-NEW HAVEN GRAIN-ABCs-FOOs', '12040-1001-ABC-FOO');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (2001, 'SALES WHEAT-NEW HAVEN GRAIN-ABCs-FOOs', '40100-1001-ABC-FOO');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (3001, 'PURCHASES WHEAT-NEW HAVEN GRAIN-ABCs-FOOs', '50110-1001-ABC-FOO');

		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (4000, 'INVENTORY WHEAT--XYZs-BARs', '12040-1000-XYZ-BAR');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (5000, 'SALES WHEAT--XYZs-BARs', '40100-1000-XYZ-BAR');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (6000, 'PURCHASES WHEAT--XYZs-BARs', '50110-1000-XYZ-BAR');
		
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (4001, 'INVENTORY WHEAT-NEW HAVEN GRAIN-XYZs-BARs', '12040-1001-XYZ-BAR');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (5001, 'SALES WHEAT-NEW HAVEN GRAIN-XYZs-BARs', '40100-1001-XYZ-BAR');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (6001, 'PURCHASES WHEAT-NEW HAVEN GRAIN-XYZs-BARs', '50110-1001-XYZ-BAR');

		-- Add fake data for Segment Mapping
		-- 'INVENTORY WHEAT--ABCs-FOOs'
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (1000, 1);
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (1000, 100);
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (1000, 500);
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (1000, 8800);
		-- 'SALES WHEAT--ABCs-FOOs'
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (2000, 2);
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (2000, 100);
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (2000, 500);
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (2000, 8800);
		-- 'PURCHASES WHEAT--ABCs-FOOs'
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (3000, 3);
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (3000, 100);
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (3000, 500);
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (3000, 8800);		
		-- 'INVENTORY WHEAT-NEW HAVEN GRAIN-ABCs-FOOs'
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (1001, 1);
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (1001, 101);
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (1001, 500);
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (1001, 8800);		
		-- 'SALES WHEAT-NEW HAVEN GRAIN-ABCs-FOOs'
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (2001, 2);
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (2001, 101);
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (2001, 500);
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (2001, 8800);		
		-- 'PURCHASES WHEAT-NEW HAVEN GRAIN-ABCs-FOOs'
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (3001, 3);
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (3001, 101);
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (3001, 500);
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (3001, 8800);

		-- 'INVENTORY WHEAT--XYZs-BARs'
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (4000, 1);
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (4000, 100);
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (4000, 501);
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (4000, 8801);
		-- 'SALES WHEAT--XYZs-BARs'
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (5000, 2);
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (5000, 100);
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (5000, 501);
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (5000, 8801);
		-- 'PURCHASES WHEAT--XYZs-BARs'
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (6000, 3);
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (6000, 100);
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (6000, 501);
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (6000, 8801);		
		-- 'INVENTORY WHEAT-NEW HAVEN GRAIN-XYZs-BARs'
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (4001, 1);
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (4001, 101);
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (4001, 501);
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (4001, 8801);		
		-- 'SALES WHEAT-NEW HAVEN GRAIN-XYZs-BARs'
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (5001, 2);
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (5001, 101);
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (5001, 501);
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (5001, 8801);		
		-- 'PURCHASES WHEAT-NEW HAVEN GRAIN-XYZs-BARs'
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (6001, 3);
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (6001, 101);
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (6001, 501);
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (6001, 8801);
END 