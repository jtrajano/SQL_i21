print 'begin updating card data'
update tblCFCard set intExpenseItemId = NULL where intExpenseItemId = 0
update tblCFCard set intDepartmentId = NULL where intDepartmentId = 0
print 'end updating card data'