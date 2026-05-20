unit uLogin;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Imaging.pngimage, Users_u;

type
  TfrmLogin = class(TForm)
    imgLogin: TImage;
    edtUsername: TEdit;
    lblUsername: TLabel;
    lblPassword: TLabel;
    btnLogin: TButton;
    gpbLogin: TGroupBox;
    edtPassword: TEdit;
    btnExit: TButton;
    lblLogin: TLabel;
    function SpaceCheck(sSpaceLogin: string): boolean;
    function LengthCheck(sLengthLogin: String): boolean;
    procedure FormActivate(Sender: TObject);
    procedure btnLoginClick(Sender: TObject);
    procedure btnExitClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Login(sUsername, sPassword: string);
    procedure JobCheck;
    procedure Logout;
    function UserLog: string;
  private
    { Private declarations }
  public
    { Public declarations }
    arrUsers: array of TUsers;
    iUsersCount: integer;
    iArrPos: integer;
  end;

var
  frmLogin: TfrmLogin;

implementation

{$R *.dfm}

uses
  uAuctions, dmPAT_DB_U, uReception, uAdministration, uOwner;

var
  tUserLog: Textfile;

function TfrmLogin.SpaceCheck(sSpaceLogin: string): boolean;
begin
  // determine if the string has spaces

  Result := True;
  if Pos(' ', sSpaceLogin) > 0 then
  begin
    Showmessage
      ('Please make sure your username and password has no spaces in it.');
    Result := False;
  end
end;

function TfrmLogin.UserLog: string;
var
  tUserLogList: TStringList;
  sLine: string;
  sID, sDate, sTime: string;
begin
  // Find last time logged on which matches user ID
  AssignFile(tUserLog, 'UsersLog.txt');
  Reset(tUserLog);

  While NOT(EOF(tUserLog)) do
  begin
    Readln(tUserLog, sLine);

    tUserLogList := TStringList.Create;
    tUserLogList.Delimiter := '#';
    tUserLogList.DelimitedText := sLine;

    sID := tUserLogList[0];

    If sID = arrUsers[iArrPos].getID then
    begin
      sDate := tUserLogList[1];
      sTime := tUserLogList[2];
    end;
  end;
  Result := Format('%s last logged in on %s at %s', [arrUsers[iArrPos].getName,
    sDate, sTime]);
  CloseFile(tUserLog);
end;

procedure TfrmLogin.btnExitClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TfrmLogin.btnLoginClick(Sender: TObject);
var
  sUsername: string;
  sPassword: string;
begin
//Validate and verify credencials
  sUsername := edtUsername.Text;
  sPassword := edtPassword.Text;
  If SpaceCheck(sUsername) = False then
    Exit
  else If SpaceCheck(sPassword) = False then
    Exit
  else If LengthCheck(sUsername) = False then
    Exit
  else If LengthCheck(sPassword) = False then
    Exit
  else
    Login(sUsername, sPassword);
end;

procedure TfrmLogin.FormActivate(Sender: TObject);
var
  tUsersLogin: Textfile;
  tUserAttributes: TStringList;
  sLine: string;
  sUsername, sPassword, sID, sJobPosition: string;

begin
  AssignFile(tUsersLogin, 'Login.txt');
  Reset(tUsersLogin);

  SetLength(arrUsers, 10);
  iUsersCount := 1;

  While NOT(EOF(tUsersLogin)) do
  begin
    If (iUsersCount >= (Length(arrUsers))) then
      SetLength(arrUsers, Length(arrUsers) * 2);

    Readln(tUsersLogin, sLine);

    tUserAttributes := TStringList.Create;
    tUserAttributes.Delimiter := '#';
    tUserAttributes.DelimitedText := frmAdministration.Decrypt(sLine);

    sUsername := tUserAttributes[0];
    sPassword := tUserAttributes[1];
    sID := tUserAttributes[2];

    If dmPAT_DB.tblUsers.Locate('Users_ID', sID, []) = False then
      Showmessage('User ID (' + sID + ') has not been found in the database.')
    else
    begin
      sJobPosition := dmPAT_DB.tblUsers['Job_Position'];

      arrUsers[iUsersCount] := Users_u.TUsers.Create(sID, sUsername, sPassword,
        sJobPosition);

      Inc(iUsersCount);
    end;
    sLine := '';
  end;
  Dec(iUsersCount);
  CloseFile(tUsersLogin);
end;

procedure TfrmLogin.FormShow(Sender: TObject);
begin
  edtPassword.Clear;
  edtUsername.Clear;
end;

procedure TfrmLogin.JobCheck;
begin
  IF arrUsers[iArrPos].getJobPosition = 'Auctioneer' then
  begin
    frmAuctions.Show;
    frmLogin.Hide;
  end
  else
  begin
    IF arrUsers[iArrPos].getJobPosition = 'Receptionist' then
    begin
      frmReception.Show;
      frmLogin.Hide;
    end
    else
    begin
      IF arrUsers[iArrPos].getJobPosition = 'Owner' then
      begin
        frmOwner.Show;
        frmLogin.Hide;
      end
      else
      begin
        IF arrUsers[iArrPos].getJobPosition = 'Administrator' then
        begin
          frmAdministration.Show;
          frmLogin.Hide;
        end
      end;
    end;
  end;
end;

procedure TfrmLogin.Login;
var
  iLoop: integer;
  bUsernameFound: boolean;
begin
  iLoop := 1;
  bUsernameFound := False;

  While (iLoop <= (iUsersCount - 1)) AND (bUsernameFound = False) do
  begin
    If arrUsers[iLoop].getUsername = sUsername then
    Begin
      bUsernameFound := True;
      If arrUsers[iLoop].getPassword = sPassword then
      begin
        iArrPos := iLoop;
        JobCheck;
      end
      else
        Showmessage('Username or password is incorrect.');
    End;
    Inc(iLoop);
  end;
  IF bUsernameFound = False then
    Showmessage('Username or password is incorrect.')
end;

procedure TfrmLogin.Logout;
begin
  // Should pherhaps delete all previous logs matching the users ID? OR Just admin deletes it?
  AssignFile(tUserLog, 'UsersLog.txt');
  Append(tUserLog);
  Writeln(tUserLog, Format('%s#%s#%s', [arrUsers[iArrPos].getID, datetostr(Now),
    timetostr(Now)]));

  CloseFile(tUserLog);
end;

function TfrmLogin.LengthCheck(sLengthLogin: String): boolean;
begin
  Result := True;
  If Length(sLengthLogin) < 10 then
  begin
    Showmessage
      ('Please make sure the username and password is at least 10 characters long.');
    Result := False;
    Exit;
  end;
end;

end.
