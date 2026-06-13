unit glfw3;

{$mode objfpc}{$H+}
interface

uses
  Classes, SysUtils, GL;

type
  GLFW_INT = integer;
  GLFWwindow = ^integer;
  GLFWmonitor = ^integer;

type
  GLFWKeyFun = procedure (p: GLFWWindow; i2, i3, i4, i5: GLFW_INT);  cdecl;
  GLFWerrorfun = procedure(i:GLFW_INT;p:pchar);cdecl;

const
  DLLNAME = 'GLFW3.DLL';

  //========================================================================
  // GLFW version
  //========================================================================
  GLFW_VERSION_MAJOR = 3;
  GLFW_VERSION_MINOR = 0;
  GLFW_VERSION_REVISION = 2;
  //*************************************************************************
  //GLFW API tokens
  //========================================================================
  GLFW_PRESS = 1;
  //========================================================================
  // Function keys
  GLFW_KEY_ESCAPE = 256;
//========================================================================

function glfwInit: integer;  cdecl; external DLLNAME;
procedure glfwTerminate; cdecl; external DLLNAME;
procedure glfwGetVersion(major, minor, rev: integer); cdecl; external DLLNAME;
function glfwCreateWindow(Width, Height: integer; title: PChar;
  monitor: GLFWmonitor; share: GLFWwindow): GLFWwindow; cdecl; external DLLNAME;
procedure glfwMakeContextCurrent(window: GLFWwindow); cdecl; external DLLNAME;
function glfwSetKeyCallback(window: GLFWwindow; cbfun: GLFWkeyfun):GLFWKeyFun; cdecl; external DLLNAME;
procedure glfwSetWindowShouldClose(window: GLFWwindow; Action: GLFW_INT); cdecl; external DLLNAME;
function glfwWindowShouldClose(Window: GLFWwindow): integer;  cdecl;  external DLLNAME;
procedure glfwSwapBuffers(window: GLFWwindow);  cdecl;  external DLLNAME;
procedure glfwPollEvents;  cdecl;  external DLLNAME;
procedure glfwDestroyWindow(Window: GLFWwindow);  cdecl;  external DLLNAME;
procedure glfwSetWindowTitle(window: GLFWwindow; title: PChar); cdecl;   external DLLNAME;
function glfwSetErrorCallback(cbfun:GLFWerrorfun):GLFWerrorfun; cdecl;  external DLLNAME;
implementation

end.
