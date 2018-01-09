using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.BusinessLayer
{
    public interface ICsvOperation<T>
    {
        T Execute(T input, CsvRecord record);
        Task<T> ExecuteAsync(T input, CsvRecord record);
    }
}
