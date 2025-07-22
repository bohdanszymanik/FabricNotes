// StatsNZPopulation
let
    Source = Table.FromRows(Json.Document(Binary.Decompress(Binary.FromText("XdOxagMxDIDhd7lZAcuWZXvvVOjU8chQQtZQCn3/3kmyzur6Yf74JGfft/ff1w1pg42gIkNNabvDvn0+v50pQTF+ez6cmYCMP75+bliVB8IwlrYyp+GnpW1cOLaNuUBb26w8KqS1rdyQANe2MSHktW3M7bjN0m7Kg/0npa3csfhpaRv/v7dxHT5BaXflzn5BaSsfY4pt44yxbbx8jrSHMlc/LW3jNvy0tE8+p8e+HWkbHyted5mTcs/Ql/bkkULbufsEz7YxprjLjMYtvJPJeH28tCdfm5f2ZA7zztmYYntyC+9kconvZDKn8E5yEc6ph11OJgr/ncm9hF0alyOy7jKTcuY4b+NyrUHaxlRj27jaQ77/AQ==", BinaryEncoding.Base64), Compression.Deflate)), let _t = ((type nullable text) meta [Serialized.Text = true]) in type table [MonthYear = _t, Population = _t]),
    #"Changed Type" = Table.TransformColumnTypes(Source,{{"MonthYear", type date}, {"Population", Int64.Type}})
in
    #"Changed Type"

// InterpolatedPopulation
let
    Source = Sql.Database("n2vzs3fnx6cetgj32......udtbuowwu.datawarehouse.fabric.microsoft.com", "Retail_Crime_Index_Lakehouse"),
    dbo_population = Source{[Schema="dbo",Item="population"]}[Data]
in
    dbo_population

// DAX CCTVMeshblockWgtn
CCTVMeshblockWgtn = 
SELECTCOLUMNS(
    FILTER(
        CCTVCamerasByMeshblock2013,
        (CCTVCamerasByMeshblock2013[TLAName] IN {"Wellington City", "Lower Hutt City", "Porirua City", "Upper Hutt City"}) &&
        NOT (CCTVCamerasByMeshblock2013[Count of Points] IN {0})

    ),
    "Meshblock", CCTVCamerasByMeshblock2013[CleanMeshblock],
    "CameraCount", CCTVCamerasByMeshblock2013[Count of Points]
)

// CCTVMeshblockChCh
CCTVMeshblockChCh = 
SELECTCOLUMNS(
    FILTER(
        CCTVCamerasByMeshblock2013,
        (CCTVCamerasByMeshblock2013[TLAName] IN {"Waimakariri", "Christchurch City"}) &&
        NOT (CCTVCamerasByMeshblock2013[Count of Points] IN {0})

    ),
    "Meshblock", CCTVCamerasByMeshblock2013[CleanMeshblock],
    "CameraCount", CCTVCamerasByMeshblock2013[Count of Points]
)

// CCTVMeshblockAkld
CCTVMeshblockAkld = 
SELECTCOLUMNS(
    FILTER(
        CCTVCamerasByMeshblock2013,
        (CCTVCamerasByMeshblock2013[TLAName] IN {"Auckland"}) &&
        NOT (CCTVCamerasByMeshblock2013[Count of Points] IN {0})

    ),
    "Meshblock", CCTVCamerasByMeshblock2013[CleanMeshblock],
    "CameraCount", CCTVCamerasByMeshblock2013[Count of Points]
)




// YearMonthVictimisationSum
let
    Source = Csv.Document(File.Contents("C:\Users\someone\OneDrive - someorg\Documents\wd\VictimisationsByPoliceStation\VictimisationsAgeROVBoundary.csv"),[Delimiter=",", Columns=21, Encoding=65001, QuoteStyle=QuoteStyle.None]),
    #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{{"Anzsoc Division", type text}, {"Year Month", type text}, {"Victimisations", Int64.Type}, {"Location Type", type text}, {"Territorial Authority", type text}, {"Police Station", type text}, {"Police District", type text}, {"Police Area", type text}, {"Person/Organisation", type text}, {"Weapons Used", type text}, {"Age Group", type text}, {"Anzsoc Group", type text}, {"Anzsoc Subdivision", type text}, {"Anzsoc Subgroup", type text}}),
    #"Added Custom" = Table.AddColumn(#"Changed Type", "YearMonth", each Date.FromText([Year Month], [Format="M/d/yyyy", Culture="us-EN"])),
    #"Grouped Rows" = Table.Group(#"Added Custom", {"YearMonth", "Location Type", "Age Group", "Anzsoc Group", "Territorial Authority", "Person/Organisation", "Weapons Used"}, {{"YearMonthVictimisations", each List.Sum([Victimisations]), type nullable number}}),
    #"Changed Type1" = Table.TransformColumnTypes(#"Grouped Rows",{{"YearMonth", type date}}),
    #"Merged Queries" = Table.NestedJoin(#"Changed Type1", {"YearMonth"}, InterpolatedPopulation, {"year_month"}, "InterpolatedPopulation", JoinKind.LeftOuter),
    #"Expanded InterpolatedPopulation" = Table.ExpandTableColumn(#"Merged Queries", "InterpolatedPopulation", {"interpolated_pop"}, {"InterpolatedPopulation.interpolated_pop"}),
    #"Added Custom1" = Table.AddColumn(#"Expanded InterpolatedPopulation", "YearMonthVictimisationsPerMillion", each [YearMonthVictimisations]*1000000 /[InterpolatedPopulation.interpolated_pop]),
    #"Changed Type2" = Table.TransformColumnTypes(#"Added Custom1",{{"YearMonthVictimisationsPerMillion", type number}})
in
    #"Changed Type2"

// VictimisationsByYearMB2021To2025
let
    Source = Csv.Document(File.Contents("C:\Users\someone\OneDrive - someorg\Documents\wd\VictimisationsByTimePlace\VictimisationsByTimePlace2021to2025.csv"),[Delimiter=",", Encoding=65001, QuoteStyle=QuoteStyle.None]),
    #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),
    #"Filtered Rows" = Table.SelectRows(#"Promoted Headers", each true),
    #"Changed Type" = Table.TransformColumnTypes(#"Filtered Rows",{{"Location Type", type text}, {"ANZSOC Division", type text}, {"Victimisations", Int64.Type}, {"ANZSOC Group", type text}, {"Meshblock", Int64.Type}, {"Year Month", type date}}),
    #"Clean Territorial Authority" = Table.TransformColumns(#"Changed Type", {{"Territorial Authority", each Text.Remove(_, {"."})}}),
    #"Added Custom" = Table.AddColumn(#"Clean Territorial Authority", "Year", each Date.Year([#"Year Month"])),
    #"Grouped Rows" = Table.Group(#"Added Custom", {"Year", "Meshblock", "Location Type", "Territorial Authority", "ANZSOC Division"}, {{"SumVictimisations", each List.Sum([Victimisations]), type nullable number}}),
    #"Renamed Columns" = Table.RenameColumns(#"Grouped Rows",{{"Meshblock", "MBRaw"}}),
    #"FilteredInvalidMeshblocks" = Table.SelectRows(#"Renamed Columns", each [MBRaw] > 0),
    #"Added Custom1" = Table.AddColumn(#"FilteredInvalidMeshblocks", "Meshblock", each Text.PadStart(Text.From([MBRaw]), 7, "0")),
    #"Merged Queries" = Table.NestedJoin(#"Added Custom1", {"Meshblock"}, CCTVCamerasByMeshblock2013, {"CleanMeshblock"}, "CCTVCamerasByMeshblock2013", JoinKind.LeftOuter),
    #"Expanded CCTVCamerasByMeshblock2013" = Table.ExpandTableColumn(#"Merged Queries", "CCTVCamerasByMeshblock2013", 
    {"CleanMeshblock", "Count of Points", "AreaUnitName", "TLAName"}, {"CCTVCamerasByMeshblock2013.CleanMeshblock", "CCTVCamerasByMeshblock2013.[Count of Points]", "CCTVCamerasByMeshblock2013.AreaUnitName","CCTVCamerasByMeshblock2013.TLAName"})
in
    #"Expanded CCTVCamerasByMeshblock2013"

// VictimisationByStationJuly2014To5May2025
let
    Source = Csv.Document(File.Contents("C:\Users\someone\OneDrive - someorg\Documents\wd\VictimisationsByPoliceStation\VictimisationByStationJuly2014To5May2025_og.csv"),[Delimiter=",", Columns=16, Encoding=65001, QuoteStyle=QuoteStyle.None]),
    #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{{"Anzsoc Division", type text}, {"Year Month", type text}, {"Victimisations", Int64.Type}, {"Location", type text}, {"Location Type", type text}, {"Territorial Authority", type text}, {"Police Station", type text}, {"Police District", type text}, {"Police Area", type text}, {"Person/Organisation", type text}, {"Weapon", type text}, {"Weapons Used", type text}, {"Age Group", type text}, {"Anzsoc Group", type text}, {"Anzsoc Subdivision", type text}, {"Anzsoc Subgroup", type text}}),
    #"Added Custom" = Table.AddColumn(#"Changed Type", "YearMonth", each Date.FromText([Year Month], [Format="M/d/yyyy", Culture="us-EN"]), Date.Type),
    #"Merged Queries" = Table.NestedJoin(#"Added Custom", {"YearMonth"}, InterpolatedPopulation, {"year_month"}, "InterpolatedPopulation", JoinKind.LeftOuter),
    #"Expanded InterpolatedPopulation" = Table.ExpandTableColumn(#"Merged Queries", "InterpolatedPopulation", {"interpolated_pop"}, {"InterpolatedPopulation.interpolated_pop"})
in
    #"Expanded InterpolatedPopulation"


let
    Source = Excel.Workbook(File.Contents("C:\Users\someone\Downloads\CCTVCamerasByMeshblock2013.xlsx"), null, true),
    CCTVCamerasByMeshblock2013_Sheet = Source{[Item="CCTVCamerasByMeshblock2013",Kind="Sheet"]}[Data],
    #"Promoted Headers" = Table.PromoteHeaders(CCTVCamerasByMeshblock2013_Sheet, [PromoteAllScalars=true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{{"OID", Int64.Type}, {"GmlID", type text}, {"Meshblock", type text}, {"MeshblockNumber", Int64.Type}, {"AreaUnitCode", Int64.Type}, {"AreaUnitName", type text}, {"UrbanAreaCode", Int64.Type}, {"UrbanAreaType", type text}, {"UrbanAreaName", type text}, {"TLACode", Int64.Type}, {"TLAName", type text}, {"WardCode", Int64.Type}, {"WardName", type text}, {"CommunityBoardCode", Int64.Type}, {"CommunityBoardName", type text}, {"TLASubdivisionCode", Int64.Type}, {"TLASubdivisionName", type text}, {"RegionalCouncilCode", Int64.Type}, {"RegionalCouncilName", type text}, {"GeneralConstituencyCode", Int64.Type}, {"GeneralConstituencyName", type text}, {"MaoriConstituencyCode", Int64.Type}, {"MaoriConstituencyName", type text}, {"GeneralElectoralDistrictCode_2007", Int64.Type}, {"GeneralElectoralDistrictName_2007", type text}, {"MaoriElectoralDistrictCode_2007", Int64.Type}, {"MaoriElectoralDistrictName_2007", type text}, {"LandCode", Int64.Type}, {"LandDescription", type text}, {"LandAreaSQKM", type number}, {"Meshblock_1", type any}, {"Shape_Length", type number}, {"Shape_Area", type number}, {"Count of Points", Int64.Type}}),
    #"Added Custom" = Table.AddColumn(#"Changed Type", "CleanMeshblock", each Text.Range([Meshblock], 3))
in
    #"Added Custom"


// ACC retail incidents
let
    Source = Table.FromRows(Json.Document(Binary.Decompress(Binary.FromText("i45WMjIwMlDSUTI3U4rVAfMMgTxDAwMY1wjENYTLGoO4RhYwrglYsZFSbCwA", BinaryEncoding.Base64), Compression.Deflate)), let _t = ((type nullable text) meta [Serialized.Text = true]) in type table [Year = _t, Claims = _t]),
    // Load or create the new rows table
    NewRowsTable = Table.FromRows(
        {
            {"2015", "92"},
            {"2016", "124"},
            {"2017", "117"},
            {"2018", "117"},
            {"2019", "78"}
        },
        {"Year", "Claims"}
    ),
    // Append the new rows to the existing table
    UpdatedTable = Table.Combine({Source, NewRowsTable}),
    #"Changed Type" = Table.TransformColumnTypes(UpdatedTable,{{"Year", Int64.Type}, {"Claims", Int64.Type}}),
    #"Sorted Rows" = Table.Sort(#"Changed Type",{{"Year", Order.Ascending}})
in
    #"Sorted Rows"
    

    
