This data fix will resolve the issues from IC-1024 and MFG-423.

Issues to fix are: 
1. Last cost in tblICLot has to be fixed. Cost should be in Stock Unit
2. GL posting is using last cost from tblICLot or the last cost calculate for tblICLot
3. Unpost (not undo the transaction) all bag off, blends and adjustments in reverse order of Batch number
4. Repost all bag offs, blends and adjustment in the same order starting from beginning.

INSTRUCTIONS: 
Here is how you can use it on your target database. 

1. Run Fix Consume.sql
2. Run Fix Produce.sql. 
3. Do #1 and #2, simultaneously, (2) two more times. Running it twice should cover 3-levels of produce-consume. WM seems to have 3 levels. 
4. Run Update tblGLSummary.sql 
5. Run Fix Inventory Adjustment.sql

The following are the quick descriptions of the scripts: 

1. Consume and Fix Produce will do the following fixes: 
	a. Remove the bad records from the cost bucket (tblICInventoryLot table). 
	b. Reduce stock from the correct cost bucket. It also creates a new record in tblICInventoryLotOut table. 
	c. Fix the last cost of the affected lot. 
	d. Correct the G/L Entries. 
	e. Both needs run twice so that it can fix those blended items used a raw material for another blend. 

2. Update tblGLSummary will re-calculate the debit and credits from the tblGLDetail table to the tblGLSummary table. 

NOTE: 
I have to modify or hack uspICPostInventoryTransaction. This is required so that Fix Consume.sql can work. This means I can’t convert the scripts into a separate stored procedure. 
We can only preserve the scripts and for use as a template in the future. I’ll keep a copy of it in our script project.  