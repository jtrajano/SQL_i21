/**
 * Created by WEstrada on 10/7/2016.
 */
Inventory.TestUtils.testViewController({
    name: 'Inventory.view.CategoryViewController',
    init: function(viewController) {
        it('should have a setupContext method', function () {
            should.exist(viewController.setupContext);
        });

        it('should have a show method', function () {
            should.exist(viewController.show);
        });

        describe("functional viewcontroller", function () {
            it('should be created successfully', function () {

            });
        })
    },
    callbacks: {
        searchConfig: function(search) {
            it('should have a search title "Search Category"', function () {
                search.title.should.be.equal("Search Category");
            });

            it('should have a search type of Inventory.Category', function() {
                search.type.should.be.equal("Inventory.Category");
            });

            it('should have a read API of ../Inventory/api/Category/Search', function () {
                search.api.read.should.be.equal("../Inventory/api/Category/Search");
            });
        },
        bindConfig: function(binding) {
            it('should have a title binding', function () {
                binding.bind.title.should.be.equal('Category - {current.strCategoryCode}');
            })
        }
    }
});