GO
PRINT('/*******************  BEGIN INSERT OTHER LABELS *******************/')

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Custom Views')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Custom Views', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Add Filter')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Add Filter', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Clear Filters')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Clear Filters', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Schema Only')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Schema Only', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Day in life')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Day in life', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Position Management')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Position Management', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Customize')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Customize', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Home')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Home', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Screens')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Screens', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Open Screens')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Open Screens', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Recent')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Recent', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Recently Viewed Records')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Recently Viewed Records', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Notifications')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Notifications', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Activities')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Activities', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Company')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Company', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Location')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Location', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Copyright')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Copyright', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'All rights reserved')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('All rights reserved', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Version')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Version', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Settings')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Settings', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Support')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Support', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Help')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Help', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Change Location')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Change Location', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Profile')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Profile', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Preferences')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Preferences', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Change Password')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Change Password', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Full Screen (F11)')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Full Screen (F11)', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Lock Screen')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Lock Screen', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Help Desk')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Help Desk', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Documentation')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Documentation', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Downloads')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Downloads', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Release Notes')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Release Notes', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'System Info')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('System Info', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'About i21')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('About i21', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Filter Menu')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Filter Menu', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'CSV (Comma Delimited)')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('CSV (Comma Delimited)', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Text (Tab Delimited)')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Text (Tab Delimited)', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Schema Only')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Schema Only', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'View')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('View', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Filter (F3)')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Filter (F3)', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Save As')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Save As', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Save As')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Save As', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Add to Menu')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Add to Menu', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Default')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Default', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Save As Default')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Save As Default', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Columns')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Columns', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Save As')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Save As', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Enable Multi-Level Grouping')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Enable Multi-Level Grouping', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Show Totals')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Show Totals', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Edited')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Edited', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Saved')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Saved', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'No Need for Approval')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('No Need for Approval', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Waiting for Approval')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Waiting for Approval', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Waiting for Submit')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Waiting for Submit', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Submitted')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Submitted', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Rejected')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Rejected', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Closed')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Closed', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Approved')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Approved', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Approved with Modifications')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Approved with Modifications', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Select Company Location')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Select Company Location', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Company Location')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Company Location', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Change Location')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Change Language', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Customize')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Customize', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Keyboard Shortcuts')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Keyboard Shortcuts', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Report Date Format')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Report Date Format', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Report Number Format')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Report Number Format', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'PDF Export Limit')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('PDF Export Limit', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Currency Decimals')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Currency Decimals', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Default Accounting Method')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Default Accounting Method', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'SMTP Email Settings')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('SMTP Email Settings', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Username')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Username', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Send Test Mail')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Send Test Mail', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Browse')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Browse', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Company Logo')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Company Logo', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Use Globally')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Use Globally', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Fax')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Fax', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Filter Columns')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Filter Columns', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'selected')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('selected', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Equals')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Equals', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Not Equal To')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Not Equal To', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Starts With')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Starts With', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Ends With')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Ends With', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Between')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Between', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Blank')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Blank', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Not Blank')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Not Blank', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Record')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Record', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Records')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Records', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Row')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Row', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Rows')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Rows', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Sort Ascending')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Sort Ascending', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Sort Descending')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Sort Descending', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Clear Sorting')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Clear Sorting', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Filter')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Filter', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Group By')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Group By', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Group By with Totals')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Group By with Totals', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Clear Group By')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Clear Group By', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Yes')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Yes', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Deleted on')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Deleted on', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Unposted on')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Unposted on', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Created - Record')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Created - Record', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Updated - Record')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Updated - Record', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Deleted - Record')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Deleted - Record', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Posted - Record')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Posted - Record', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Unposted - Record')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Unposted - Record', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Processed - Record')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Processed - Record', 1)
END

--========================================== Messages =====================================================--

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Do you want to save the changes you made?')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Do you want to save the changes you made?', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Are you sure you want to delete this record?')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Are you sure you want to delete this record?', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'You are about to delete')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('You are about to delete', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Are you sure you want to continue?')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Are you sure you want to continue?', 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMScreenLabel WHERE strLabel = 'Are you sure you want to logout?')
BEGIN
	INSERT INTO tblSMScreenLabel (strLabel, intConcurrencyId)
	VALUES ('Are you sure you want to logout?', 1)
END

--======================================== End Messages ===================================================--


PRINT('/*******************  END INSERT OTHER LABELS  *******************/')

GO