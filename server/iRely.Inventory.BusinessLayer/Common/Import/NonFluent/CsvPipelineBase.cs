using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.BusinessLayer
{
    public abstract class CsvPipelineBase<T>
    {
        private readonly List<ICsvOperation<T>> operations = new List<ICsvOperation<T>>();

        public CsvPipelineBase<T> Register(ICsvOperation<T> operation)
        {
            operations.Add(operation);
            return this;
        }

        public T PerformOperation(T input, CsvRecord record)
        {
            return operations.Aggregate(input, (current, operation) => operation.Execute(current, record));
        }

        public async Task<T> PerformOperationAsync(T input, CsvRecord record)
        {
            return await operations.Aggregate(Task.FromResult<T>(input), async (current, operation) => (await operation.ExecuteAsync(input, record)));
        }
    }
}
