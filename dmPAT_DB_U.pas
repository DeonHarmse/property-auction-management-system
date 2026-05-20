unit dmPAT_DB_U;

interface

uses
  System.SysUtils, System.Classes, Data.DB, Data.Win.ADODB;

type
  TdmPAT_DB = class(TDataModule)
    procedure DataModuleCreate(Sender: TObject);
    procedure runSQL(sStatement: string);
    procedure runSQLB(sDistinctStatement: string);
    procedure runSQLC(sStatement: string);
  private
    { Private declarations }
  public
    { Public declarations }
    conDM_PAT_DB: TADOConnection;

    tblProperties: TADOTable;
    dsProperties: TDataSource;

    tblBuyers: TADOTable;
    dsBuyers: TDataSource;

    tblSellers: TADOTable;
    dsSellers: TDataSource;

    tblAuctions: TADOTable;
    dsAuctions: TDataSource;

    tblUsers: TADOTable;
    dsUsers: TDataSource;

    // ---Query Variables---
    qryA: TADOQuery;
    dsQryA: TDataSource;

    qryB: TADOQuery;
    dsQryB: TDataSource;

    qryC: TADOQuery;
    dsQryC: TDataSource;
  end;

var
  dmPAT_DB: TdmPAT_DB;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}
{$R *.dfm}
{ TdmPAT_DB }

procedure TdmPAT_DB.DataModuleCreate(Sender: TObject);
begin
  // Create and set connection
  conDM_PAT_DB := TADOConnection.Create(dmPAT_DB);
  conDM_PAT_DB.ConnectionString :=
    'Provider=Microsoft.Jet.OLEDB.4.0;Data Source=' +
    ExtractFilePath(ParamStr(0)) + 'PAT_DB.MDB;Persist Security Info=False';
  conDM_PAT_DB.LoginPrompt := false;

  // Create and set tables and datasources
  tblProperties := TADOTable.Create(dmPAT_DB);
  dsProperties := TDataSource.Create(dmPAT_DB);

  tblBuyers := TADOTable.Create(dmPAT_DB);
  dsBuyers := TDataSource.Create(dmPAT_DB);

  tblSellers := TADOTable.Create(dmPAT_DB);
  dsSellers := TDataSource.Create(dmPAT_DB);

  tblAuctions := TADOTable.Create(dmPAT_DB);
  dsAuctions := TDataSource.Create(dmPAT_DB);

  tblUsers := TADOTable.Create(dmPAT_DB);
  dsUsers := TDataSource.Create(dmPAT_DB);

  // ----Create Query----
  qryA := TADOQuery.Create(dmPAT_DB);
  dsQryA := TDataSource.Create(dmPAT_DB);

  qryB := TADOQuery.Create(dmPAT_DB);
  dsQryB := TDataSource.Create(dmPAT_DB);

  qryC := TADOQuery.Create(dmPAT_DB);
  dsQryC := TDataSource.Create(dmPAT_DB);

  // Assign table connections and table names
  tblProperties.Connection := conDM_PAT_DB;
  tblProperties.TableName := 'tblProperties';

  tblBuyers.Connection := conDM_PAT_DB;
  tblBuyers.TableName := 'tblBuyers';

  tblSellers.Connection := conDM_PAT_DB;
  tblSellers.TableName := 'tblSellers';

  tblAuctions.Connection := conDM_PAT_DB;
  tblAuctions.TableName := 'tblAuctions';

  tblUsers.Connection := conDM_PAT_DB;
  tblUsers.TableName := 'tblUsers';

  // ----Assign Query Connection----
  qryA.Connection := conDM_PAT_DB;
  qryB.Connection := conDM_PAT_DB;
  qryC.Connection := conDM_PAT_DB;

  // Assign datasets and open tables
  dsProperties.DataSet := tblProperties;
  dsBuyers.DataSet := tblBuyers;
  dsSellers.DataSet := tblSellers;
  dsAuctions.DataSet := tblAuctions;
  dsUsers.DataSet := tblUsers;

  tblProperties.Open;
  tblBuyers.Open;
  tblSellers.Open;
  tblAuctions.Open;
  tblUsers.Open;

  // ----Connect data source to Query----
  dsQryA.DataSet := qryA;
  dsQryB.DataSet := qryB;
  dsQryC.DataSet := qryC;

  // Open connection
  dmPAT_DB.conDM_PAT_DB.Open;
end;

procedure TdmPAT_DB.runSQLB(sDistinctStatement: string);
begin
  qryB.Close;
  qryB.SQL.Text := sDistinctStatement;
  qryB.Open;
end;

procedure TdmPAT_DB.runSQLC(sStatement: string);
begin
  qryC.Close;
  qryC.SQL.Text := sStatement;
  qryC.Open;
end;

procedure TdmPAT_DB.runSQL(sStatement: string);
begin
  qryA.Close;
  qryA.SQL.Text := sStatement;
  qryA.Open;
end;

end.
