print('/*******************  BEGIN Update Commodity Items into Inventory Items *******************/')
GO

UPDATE tblICItem
SET strType = 'Inventory'
WHERE strType = 'Commodity'

print('/*******************  END Update Commodity Items into Inventory Items *******************/')
GO