using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICInventoryCountMap: EntityTypeConfiguration<tblICInventoryCount>
    {
        public tblICInventoryCountMap()
        {
            // Primary Key
            this.HasKey(t => t.intInventoryCountId);

            // Table & Column Mappings
            this.ToTable("tblICInventoryCount");
            this.Property(t => t.intInventoryCountId).HasColumnName("intInventoryCountId");
            this.Property(t => t.intLocationId).HasColumnName("intLocationId");
            this.Property(t => t.intCategoryId).HasColumnName("intCategoryId");
            this.Property(t => t.intCommodityId).HasColumnName("intCommodityId");
            this.Property(t => t.intCountGroupId).HasColumnName("intCountGroupId");
            this.Property(t => t.dtmCountDate).HasColumnName("dtmCountDate");
            this.Property(t => t.strCountNo).HasColumnName("strCountNo");
            this.Property(t => t.intSubLocationId).HasColumnName("intSubLocationId");
            this.Property(t => t.intStorageLocationId).HasColumnName("intStorageLocationId");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            this.Property(t => t.ysnIncludeZeroOnHand).HasColumnName("ysnIncludeZeroOnHand");
            this.Property(t => t.ysnIncludeOnHand).HasColumnName("ysnIncludeOnHand");
            this.Property(t => t.ysnScannedCountEntry).HasColumnName("ysnScannedCountEntry");
            this.Property(t => t.ysnCountByLots).HasColumnName("ysnCountByLots");
            this.Property(t => t.ysnCountByPallets).HasColumnName("ysnCountByPallets");
            this.Property(t => t.ysnRecountMismatch).HasColumnName("ysnRecountMismatch");
            this.Property(t => t.ysnExternal).HasColumnName("ysnExternal");
            this.Property(t => t.ysnRecount).HasColumnName("ysnRecount");
            this.Property(t => t.intRecountReferenceId).HasColumnName("intRecountReferenceId");
            this.Property(t => t.intStatus).HasColumnName("intStatus");
            this.Property(t => t.ysnPosted).HasColumnName("ysnPosted");
            this.Property(t => t.dtmPosted).HasColumnName("dtmPosted");
            this.Property(t => t.intImportFlagInternal).HasColumnName("intImportFlagInternal");
            this.Property(t => t.intEntityId).HasColumnName("intEntityId");
            this.Property(t => t.intSort).HasColumnName("intSort");

            this.HasMany(p => p.tblICInventoryCountDetails)
                .WithRequired(p => p.tblICInventoryCount)
                .HasForeignKey(p => p.intInventoryCountId);
        }
    }

    public class tblICInventoryCountDetailMap : EntityTypeConfiguration<tblICInventoryCountDetail>
    {
        public tblICInventoryCountDetailMap()
        {
            // Primary Key
            this.HasKey(t => t.intInventoryCountDetailId);

            // Table & Column Mappings
            this.ToTable("tblICInventoryCountDetail");
            this.Property(t => t.intInventoryCountDetailId).HasColumnName("intInventoryCountDetailId");
            this.Property(t => t.intInventoryCountId).HasColumnName("intInventoryCountId");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intItemLocationId).HasColumnName("intItemLocationId");
            this.Property(t => t.intSubLocationId).HasColumnName("intSubLocationId");
            this.Property(t => t.intStorageLocationId).HasColumnName("intStorageLocationId");
            this.Property(t => t.intLotId).HasColumnName("intLotId");
            this.Property(t => t.dblSystemCount).HasColumnName("dblSystemCount").HasPrecision(38, 20);
            this.Property(t => t.dblLastCost).HasColumnName("dblLastCost").HasPrecision(38, 20);
            this.Property(t => t.strCountLine).HasColumnName("strCountLine");
            this.Property(t => t.dblPallets).HasColumnName("dblPallets").HasPrecision(38, 20);
            this.Property(t => t.dblQtyPerPallet).HasColumnName("dblQtyPerPallet").HasPrecision(38, 20);
            this.Property(t => t.dblPhysicalCount).HasColumnName("dblPhysicalCount").HasPrecision(38, 20);
            this.Property(t => t.intItemUOMId).HasColumnName("intItemUOMId");
            this.Property(t => t.ysnRecount).HasColumnName("ysnRecount");
            this.Property(t => t.intEntityUserSecurityId).HasColumnName("intEntityUserSecurityId");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.strAutoCreatedLotNumber).HasColumnName("strAutoCreatedLotNumber");

            this.HasOptional(p => p.vyuICGetInventoryCountDetail)
                .WithRequired(p => p.tblICInventoryCountDetail);
        }
    }

    public class vyuICGetInventoryCountMap : EntityTypeConfiguration<vyuICGetInventoryCount>
    {
        public vyuICGetInventoryCountMap()
        {
            // Primary Key
            this.HasKey(t => t.intInventoryCountId);

            // Table & Column Mappings
            this.ToTable("vyuICGetInventoryCount");
            this.Property(t => t.intInventoryCountId).HasColumnName("intInventoryCountId");
            this.Property(t => t.intLocationId).HasColumnName("intLocationId");
            this.Property(t => t.strLocationName).HasColumnName("strLocationName");
            this.Property(t => t.intCategoryId).HasColumnName("intCategoryId");
            this.Property(t => t.strCategory).HasColumnName("strCategory");
            this.Property(t => t.intCommodityId).HasColumnName("intCommodityId");
            this.Property(t => t.strCommodity).HasColumnName("strCommodity");
            this.Property(t => t.intCountGroupId).HasColumnName("intCountGroupId");
            this.Property(t => t.strCountGroup).HasColumnName("strCountGroup");
            this.Property(t => t.dtmCountDate).HasColumnName("dtmCountDate");
            this.Property(t => t.strCountNo).HasColumnName("strCountNo");
            this.Property(t => t.intSubLocationId).HasColumnName("intSubLocationId");
            this.Property(t => t.strSubLocationName).HasColumnName("strSubLocationName");
            this.Property(t => t.intStorageLocationId).HasColumnName("intStorageLocationId");
            this.Property(t => t.strStorageLocationName).HasColumnName("strStorageLocationName");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            this.Property(t => t.ysnIncludeZeroOnHand).HasColumnName("ysnIncludeZeroOnHand");
            this.Property(t => t.ysnIncludeOnHand).HasColumnName("ysnIncludeOnHand");
            this.Property(t => t.ysnScannedCountEntry).HasColumnName("ysnScannedCountEntry");
            this.Property(t => t.ysnCountByLots).HasColumnName("ysnCountByLots");
            this.Property(t => t.ysnCountByPallets).HasColumnName("ysnCountByPallets");
            this.Property(t => t.ysnRecountMismatch).HasColumnName("ysnRecountMismatch");
            this.Property(t => t.ysnExternal).HasColumnName("ysnExternal");
            this.Property(t => t.ysnRecount).HasColumnName("ysnRecount");
            this.Property(t => t.intRecountReferenceId).HasColumnName("intRecountReferenceId");
            this.Property(t => t.intStatus).HasColumnName("intStatus");
            this.Property(t => t.strStatus).HasColumnName("strStatus");
            this.Property(t => t.intSort).HasColumnName("intSort");
        }
    }

    public class vyuICGetInventoryCountDetailMap : EntityTypeConfiguration<vyuICGetInventoryCountDetail>
    {
        public vyuICGetInventoryCountDetailMap()
        {
            // Primary Key
            this.HasKey(t => t.intInventoryCountDetailId);

            // Table & Column Mappings
            this.ToTable("vyuICGetInventoryCountDetail");
            this.Property(t => t.intInventoryCountDetailId).HasColumnName("intInventoryCountDetailId");
            this.Property(t => t.intInventoryCountId).HasColumnName("intInventoryCountId");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.strItemNo).HasColumnName("strItemNo");
            this.Property(t => t.strItemDescription).HasColumnName("strItemDescription");
            this.Property(t => t.strLotTracking).HasColumnName("strLotTracking");
            this.Property(t => t.intCategoryId).HasColumnName("intCategoryId");
            this.Property(t => t.strCategory).HasColumnName("strCategory");
            this.Property(t => t.intItemLocationId).HasColumnName("intItemLocationId");
            this.Property(t => t.strLocationName).HasColumnName("strLocationName");
            this.Property(t => t.intSubLocationId).HasColumnName("intSubLocationId");
            this.Property(t => t.strSubLocationName).HasColumnName("strSubLocationName");
            this.Property(t => t.intStorageLocationId).HasColumnName("intStorageLocationId");
            this.Property(t => t.strStorageLocationName).HasColumnName("strStorageLocationName");
            this.Property(t => t.intLotId).HasColumnName("intLotId");
            this.Property(t => t.strLotNumber).HasColumnName("strLotNumber");
            this.Property(t => t.strLotAlias).HasColumnName("strLotAlias");
            this.Property(t => t.dblSystemCount).HasColumnName("dblSystemCount").HasPrecision(38, 20);
            this.Property(t => t.dblLastCost).HasColumnName("dblLastCost").HasPrecision(38, 20);
            this.Property(t => t.strCountLine).HasColumnName("strCountLine");
            this.Property(t => t.dblPallets).HasColumnName("dblPallets").HasPrecision(38, 20);
            this.Property(t => t.dblQtyPerPallet).HasColumnName("dblQtyPerPallet").HasPrecision(38, 20);
            this.Property(t => t.dblPhysicalCount).HasColumnName("dblPhysicalCount").HasPrecision(38, 20);
            this.Property(t => t.intItemUOMId).HasColumnName("intItemUOMId");
            this.Property(t => t.strUnitMeasure).HasColumnName("strUnitMeasure");
            this.Property(t => t.dblConversionFactor).HasColumnName("dblConversionFactor").HasPrecision(38, 20);
            this.Property(t => t.dblPhysicalCountStockUnit).HasColumnName("dblPhysicalCountStockUnit").HasPrecision(38, 20);
            this.Property(t => t.dblVariance).HasColumnName("dblVariance").HasPrecision(38, 20);
            this.Property(t => t.ysnRecount).HasColumnName("ysnRecount");
            this.Property(t => t.intEntityUserSecurityId).HasColumnName("intEntityUserSecurityId");
            this.Property(t => t.strUserName).HasColumnName("strUserName");
            this.Property(t => t.intSort).HasColumnName("intSort");
        }
    }

    public class vyuICGetCountSheetMap : EntityTypeConfiguration<vyuICGetCountSheet>
    {
        public vyuICGetCountSheetMap()
        {
            // Primary Key
            this.HasKey(t => t.intInventoryCountDetailId);

            // Table & Column Mappings
            this.ToTable("vyuICGetCountSheet");
            this.Property(t => t.intLocationId).HasColumnName("intLocationId");
            this.Property(t => t.intCommodityId).HasColumnName("intCommodityId");
            this.Property(t => t.strCommodity).HasColumnName("strCommodity");
            this.Property(t => t.strCountNo).HasColumnName("strCountNo");
            this.Property(t => t.dtmCountDate).HasColumnName("dtmCountDate");
            this.Property(t => t.intInventoryCountDetailId).HasColumnName("intInventoryCountDetailId");
            this.Property(t => t.intInventoryCountId).HasColumnName("intInventoryCountId");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.strItemNo).HasColumnName("strItemNo");
            this.Property(t => t.strItemDescription).HasColumnName("strItemDescription");
            this.Property(t => t.strLotTracking).HasColumnName("strLotTracking");
            this.Property(t => t.intCategoryId).HasColumnName("intCategoryId");
            this.Property(t => t.strCategory).HasColumnName("strCategory");
            this.Property(t => t.intItemLocationId).HasColumnName("intItemLocationId");
            this.Property(t => t.strLocationName).HasColumnName("strLocationName");
            this.Property(t => t.intSubLocationId).HasColumnName("intSubLocationId");
            this.Property(t => t.strSubLocationName).HasColumnName("strSubLocationName");
            this.Property(t => t.intStorageLocationId).HasColumnName("intStorageLocationId");
            this.Property(t => t.strStorageLocationName).HasColumnName("strStorageLocationName");
            this.Property(t => t.intLotId).HasColumnName("intLotId");
            this.Property(t => t.strLotNumber).HasColumnName("strLotNumber");
            this.Property(t => t.strLotAlias).HasColumnName("strLotAlias");
            this.Property(t => t.dblSystemCount).HasColumnName("dblSystemCount").HasPrecision(38, 20);
            this.Property(t => t.dblLastCost).HasColumnName("dblLastCost").HasPrecision(38, 20);
            this.Property(t => t.strCountLine).HasColumnName("strCountLine");
            this.Property(t => t.dblPallets).HasColumnName("dblPallets").HasPrecision(38, 20);
            this.Property(t => t.dblQtyPerPallet).HasColumnName("dblQtyPerPallet").HasPrecision(38, 20);
            this.Property(t => t.dblPhysicalCount).HasColumnName("dblPhysicalCount").HasPrecision(38, 20);
            this.Property(t => t.intItemUOMId).HasColumnName("intItemUOMId");
            this.Property(t => t.strUnitMeasure).HasColumnName("strUnitMeasure");
            this.Property(t => t.dblPhysicalCountStockUnit).HasColumnName("dblPhysicalCountStockUnit").HasPrecision(38, 20);
            this.Property(t => t.dblVariance).HasColumnName("dblVariance").HasPrecision(38, 20);
            this.Property(t => t.ysnRecount).HasColumnName("ysnRecount");
            this.Property(t => t.intEntityUserSecurityId).HasColumnName("intEntityUserSecurityId");
            this.Property(t => t.strUserName).HasColumnName("strUserName");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.ysnCountByLots).HasColumnName("ysnCountByLots");
            this.Property(t => t.ysnCountByPallets).HasColumnName("ysnCountByPallets");
            this.Property(t => t.ysnIncludeOnHand).HasColumnName("ysnIncludeOnHand");
            this.Property(t => t.ysnIncludeZeroOnHand).HasColumnName("ysnIncludeZeroOnHand");
            this.Property(t => t.dblPalletsBlank).HasColumnName("dblPalletsBlank");
            this.Property(t => t.dblQtyPerPalletBlank).HasColumnName("dblQtyPerPalletBlank");
            this.Property(t => t.dblPhysicalCountBlank).HasColumnName("dblPhysicalCountBlank");    
        }
    }

    public class vyuICGetItemStockSummaryMap : EntityTypeConfiguration<vyuICGetItemStockSummary>
    {
        public vyuICGetItemStockSummaryMap()
        {
            // Primary Key
            this.HasKey(t => t.intKey);

            // Table & Column Mappings
            this.ToTable("vyuICGetItemStockSummary");
            this.Property(t => t.intKey).HasColumnName("intKey");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.strItemNo).HasColumnName("strItemNo");
            this.Property(t => t.strItemDescription).HasColumnName("strItemDescription");
            this.Property(t => t.strLotTracking).HasColumnName("strLotTracking");
            this.Property(t => t.intCategoryId).HasColumnName("intCategoryId");
            this.Property(t => t.strCategoryCode).HasColumnName("strCategoryCode");
            this.Property(t => t.intCommodityId).HasColumnName("intCommodityId");
            this.Property(t => t.strCommodityCode).HasColumnName("strCommodityCode");
            this.Property(t => t.intItemLocationId).HasColumnName("intItemLocationId");
            this.Property(t => t.intLocationId).HasColumnName("intLocationId");
            this.Property(t => t.intCountGroupId).HasColumnName("intCountGroupId");
            this.Property(t => t.strLocationName).HasColumnName("strLocationName");
            this.Property(t => t.intSubLocationId).HasColumnName("intSubLocationId");
            this.Property(t => t.strSubLocationName).HasColumnName("strSubLocationName");
            this.Property(t => t.intStorageLocationId).HasColumnName("intStorageLocationId");
            this.Property(t => t.strStorageLocationName).HasColumnName("strStorageLocationName");
            this.Property(t => t.intItemUOMId).HasColumnName("intItemUOMId");
            this.Property(t => t.strUnitMeasure).HasColumnName("strUnitMeasure");
            this.Property(t => t.dblStockIn).HasColumnName("dblStockIn").HasPrecision(38, 20);
            this.Property(t => t.dblStockOut).HasColumnName("dblStockOut").HasPrecision(38, 20);
            this.Property(t => t.dblOnHand).HasColumnName("dblOnHand").HasPrecision(38, 20);
            this.Property(t => t.dblConversionFactor).HasColumnName("dblConversionFactor").HasPrecision(38, 20);
            this.Property(t => t.dblLastCost).HasColumnName("dblLastCost").HasPrecision(38, 20);
            this.Property(t => t.dblTotalCost).HasColumnName("dblTotalCost").HasPrecision(38, 20);
        }
    }

    public class vyuICGetItemStockSummaryByLotMap : EntityTypeConfiguration<vyuICGetItemStockSummaryByLot>
    {
        public vyuICGetItemStockSummaryByLotMap()
        {
            // Primary Key
            this.HasKey(t => t.intKey);

            // Table & Column Mappings
            this.ToTable("vyuICGetItemStockSummaryByLot");
            this.Property(t => t.intKey).HasColumnName("intKey");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.strItemNo).HasColumnName("strItemNo");
            this.Property(t => t.strItemDescription).HasColumnName("strItemDescription");
            this.Property(t => t.strLotTracking).HasColumnName("strLotTracking");
            this.Property(t => t.intCategoryId).HasColumnName("intCategoryId");
            this.Property(t => t.strCategoryCode).HasColumnName("strCategoryCode");
            this.Property(t => t.intCommodityId).HasColumnName("intCommodityId");
            this.Property(t => t.strCommodityCode).HasColumnName("strCommodityCode");
            this.Property(t => t.intItemLocationId).HasColumnName("intItemLocationId");
            this.Property(t => t.intLocationId).HasColumnName("intLocationId");
            this.Property(t => t.intCountGroupId).HasColumnName("intCountGroupId");
            this.Property(t => t.strLocationName).HasColumnName("strLocationName");
            this.Property(t => t.intSubLocationId).HasColumnName("intSubLocationId");
            this.Property(t => t.strSubLocationName).HasColumnName("strSubLocationName");
            this.Property(t => t.intStorageLocationId).HasColumnName("intStorageLocationId");
            this.Property(t => t.strStorageLocationName).HasColumnName("strStorageLocationName");
            this.Property(t => t.intItemUOMId).HasColumnName("intItemUOMId");
            this.Property(t => t.strUnitMeasure).HasColumnName("strUnitMeasure");
            this.Property(t => t.intLotId).HasColumnName("intLotId");
            this.Property(t => t.strLotNumber).HasColumnName("strLotNumber");
            this.Property(t => t.strLotAlias).HasColumnName("strLotAlias");
            this.Property(t => t.dblStockIn).HasColumnName("dblStockIn").HasPrecision(38, 20);
            this.Property(t => t.dblStockOut).HasColumnName("dblStockOut").HasPrecision(38, 20);
            this.Property(t => t.dblOnHand).HasColumnName("dblOnHand").HasPrecision(38, 20);
            this.Property(t => t.dblConversionFactor).HasColumnName("dblConversionFactor").HasPrecision(38, 20);
            this.Property(t => t.dblLastCost).HasColumnName("dblLastCost").HasPrecision(38, 20);
            this.Property(t => t.dblTotalCost).HasColumnName("dblTotalCost").HasPrecision(38, 20);
        }
    }
}
