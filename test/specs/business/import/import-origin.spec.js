describe("Import Origins", function() {
    var vm;
    var LOB = 'lineOfBusiness',
        PETRO = "Petro",
        TASK= "currentTask";

    before(function() {
        vm = Ext.create('Inventory.view.OriginConversionOptionViewModel');    
    });

    describe("Origin Steps Toggling", function() {
        it("should set current task to LOB when nothing has imported yet", function() {
            var lob = vm.get(LOB);
            var task = vm.get(TASK);

            lob.should.be.equal('');
            task.should.be.equal('LOB');
        });

        describe("Petro", function() {
            before(function() {
                vm.set(LOB, PETRO);
            });

            it("should set Line of Business to Petro", function() {
                vm.get(LOB).should.be.equal(PETRO);
            });
    
            it("should disable LOB when task is UOM", function() {    
                var lob = vm.get(LOB);
                var task = vm.get(TASK);
                var enabled = task === 'LOB';
                
                enabled.should.be.true();
            });

            it("should disable UOM when task is UOM & LOB should be disabled", function() {
                var lob = vm.get(LOB);
                var task = vm.get(TASK);
                var enabled = task === 'UOM';

                enabled.should.be.true();
            });
        })
    })
});