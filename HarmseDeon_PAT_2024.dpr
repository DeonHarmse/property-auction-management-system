program HarmseDeon_PAT_2024;

uses
  Vcl.Forms,
  uLogin in 'uLogin.pas' {frmLogin},
  uAuctions in 'uAuctions.pas' {frmAuctions},
  uReception in 'uReception.pas' {frmReception},
  uAdministration in 'uAdministration.pas' {frmAdministration},
  dmPAT_DB_U in 'dmPAT_DB_U.pas' {dmPAT_DB: TDataModule},
  uAuction2 in 'uAuction2.pas' {frmAuction2},
  Users_u in 'Users_u.pas',
  uOwner in 'uOwner.pas' {frmOwner};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmLogin, frmLogin);
  Application.CreateForm(TfrmAuctions, frmAuctions);
  Application.CreateForm(TfrmReception, frmReception);
  Application.CreateForm(TfrmAdministration, frmAdministration);
  Application.CreateForm(TdmPAT_DB, dmPAT_DB);
  Application.CreateForm(TfrmAuction2, frmAuction2);
  Application.CreateForm(TfrmOwner, frmOwner);
  Application.Run;
end.
