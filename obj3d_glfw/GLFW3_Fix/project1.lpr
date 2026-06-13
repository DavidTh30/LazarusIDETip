program project1;

{$mode objfpc}{$H+}

uses {$IFDEF UNIX} {$IFDEF UseCThreads}
  cthreads, {$ENDIF} {$ENDIF}
  Classes { you can add units after this },
  SysUtils,
  glfw3,
  gl,math;

var
  R: integer;
  Revision: integer;
  Menor: integer;
  Mayor: integer;
  H: GLFWwindow;
  y: GLFWKeyFun;

  procedure Key_CallBack(aWindow: GLFWwindow; aKey: GLFW_INT;
    aScanCode: GLFW_INT; aAction: GLFW_INT; aMod: GLFW_INT);cdecl;
  var
    Salir: integer;
  begin
    if (akey = GLFW_KEY_ESCAPE) and (aAction = GLFW_PRESS) then
    begin
      glfwSetWindowShouldClose(aWindow, gl_true);
    end;
  end;

  procedure errorcb(i:GLFW_INT;p:pchar);cdecl;

  begin
    writeln(p);
  end;

begin
  R := glfwInit;
  glfwSetErrorCallback(@errorcb);
  WriteLn(IntToStr(r));
  H := glfwCreateWindow(64, 48, 'sample', nil, nil);
  glfwMakeContextCurrent(H);
  y := glfwSetKeyCallback(h, @Key_CallBack);
  glfwSetWindowTitle(h, PChar('pepito'));
  while (glfwWindowShouldClose(h) = GL_FALSE) do
  begin
    glfwSwapBuffers(h);
    glfwPollEvents;
  end;
  glfwDestroyWindow(h);
  glfwTerminate;
end.
