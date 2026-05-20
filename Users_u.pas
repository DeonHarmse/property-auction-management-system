unit Users_u;

interface

type
  TUsers = class(TObject)
  private
  var
    fID: String;
    fUsername: String;
    fPassword: String;
    fName: string;
    fJobPosition: string;
  public
    constructor create(sID, sUsername, sPassword,sJobPosition: string);
    procedure setUsername(sNewUsername: string);
    procedure setPassword(sNewPassword: string);
    procedure setID(sNewID: string);

    function getName: string;
    function getID: string;
    function getUsername: string;
    function getPassword: string;
    function getJobPosition: string;

  end;

implementation

Uses
  SysUtils;
{ TUsers }

constructor TUsers.create(sID, sUsername, sPassword, sJobPosition: string);
begin
  fID := sID;
  fUsername := sUsername;
  fPassword := sPassWord;
  fJobPosition:= sJobPosition;
end;

function TUsers.getID: string;
begin
  Result := fID;
end;

function TUsers.getJobPosition: string;
begin
 Result:= fJobPosition;
end;

function TUsers.getName: string;
begin
  Result := fName;
end;

function TUsers.getPassword: string;
begin
  Result := fPassword;
end;

function TUsers.getUsername: string;
begin
  Result := fUsername;
end;

procedure TUsers.setID(sNewID: string);
begin
  fID := sNewID;
end;

procedure TUsers.setPassword(sNewPassword: string);
begin
  fPassword := sNewPassword;
end;

procedure TUsers.setUsername(sNewUsername: string);
begin
  fUsername := sNewUsername;
end;

end.
