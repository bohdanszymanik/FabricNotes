// write out the whole power bi database as a bunch of tdmls - this is so cool!

#r "System.Xml.Linq"
#r "nuget: Microsoft.AnalysisServices"
#r "nuget: Microsoft.AnalysisServices.AdomdClient"


let server = new Microsoft.AnalysisServices.Tabular.Server()

server.Connect("powerbi://api.powerbi.com/v1.0/<some organisation>/<Some shared workspace>")
let dbs = server.Databases.GetByName("Victimisations2014To2025")


dbs
dbs.Model

let out = @"C:\Users\BhodanSzymanilk\wd\TDMLScript\v-tdml"

Microsoft.AnalysisServices.Tabular.TmdlSerializer.SerializeDatabaseToFolder(dbs, out);
