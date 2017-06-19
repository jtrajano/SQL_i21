using System;
using System.Collections.Generic;
using System.Linq;
using System.Data.Entity;
using System.Data.SqlClient;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public partial class InventoryEntities : DbContext
    {
        public async Task<decimal> GetUnitConversion(int? fromUnitMeasureId, int? toUnitMeasureId)
        {
            decimal? conversion = null;

            var fromUnitMeasureIdParam = new SqlParameter("@fromUnitMeasureId", fromUnitMeasureId);
            fromUnitMeasureIdParam.DbType = System.Data.DbType.Int32;
            fromUnitMeasureIdParam.SqlDbType = System.Data.SqlDbType.Int;

            var toUnitMeasureIdParam = new SqlParameter("@toUnitMeasureId", toUnitMeasureId);
            toUnitMeasureIdParam.DbType = System.Data.DbType.Int32;
            toUnitMeasureIdParam.SqlDbType = System.Data.SqlDbType.Int;
            
            var resultParam = new SqlParameter("@result", conversion);
            resultParam.Direction = System.Data.ParameterDirection.Output;
            resultParam.DbType = System.Data.DbType.Decimal;
            resultParam.SqlDbType = System.Data.SqlDbType.Decimal;
            resultParam.Precision = 38;
            resultParam.Scale = 20;

            await this.Database.ExecuteSqlCommandAsync(
                "uspICGetUnitConversion @fromUnitMeasureId, @toUnitMeasureId, @result OUTPUT",
                fromUnitMeasureIdParam,
                toUnitMeasureIdParam,
                resultParam
            );

            return resultParam.Value == DBNull.Value ? 0m: (decimal)resultParam.Value;
        }
    }
}
