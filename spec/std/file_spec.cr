#!/usr/bin/env bin/crystal --run
require "spec"

describe "File" do
  it "reads entire file" do
    str = File.read "#{__DIR__}/data/test_file.txt"
    str.should eq("Hello World\n" * 20)
  end

  it "reads lines from file" do
    lines = File.read_lines "#{__DIR__}/data/test_file.txt"
    lines.length.should eq(20)
    lines.first.should eq("Hello World\n")
  end

  it "reads lines from file with each" do
    idx = 0
    File.each_line("#{__DIR__}/data/test_file.txt") do |line|
      if idx == 0
        line.should eq("Hello World\n")
      end
      idx += 1
    end
    idx.should eq(20)
  end

  it "tests exists? and gives true" do
    File.exists?("#{__DIR__}/data/test_file.txt").should be_true
  end

  it "tests exists? and gives false" do
    File.exists?("#{__DIR__}/data/non_existing_file.txt").should be_false
  end

  it "gets dirname" do
    File.dirname("/Users/foo/bar.cr").should eq("/Users/foo")
    File.dirname("foo").should eq(".")
    File.dirname("").should eq(".")
  end

  it "gets basename" do
    File.basename("/foo/bar/baz.cr").should eq("baz.cr")
    File.basename("/foo/").should eq("foo")
    File.basename("foo").should eq("foo")
    File.basename("").should eq("")
  end

  it "gets basename removing suffix" do
    File.basename("/foo/bar/baz.cr", ".cr").should eq("baz")
  end

  it "gets extname" do
    File.extname("/foo/bar/baz.cr").should eq(".cr")
    File.extname("/foo/bar/baz.cr.cz").should eq(".cz")
    File.extname("/foo/bar/.profile").should eq("")
    File.extname("/foo/bar/.profile.sh").should eq(".sh")
    File.extname("/foo/bar/foo.").should eq("")
    File.extname("test").should eq("")
  end

  it "constructs a path from parts" do
    File.join(["///foo", "bar"]).should eq("/foo/bar")
    File.join(["///foo", "//bar"]).should eq("/foo/bar")
    File.join(["foo", "bar", "baz"]).should eq("foo/bar/baz")
    File.join(["foo", "//bar//", "baz///"]).should eq("foo/bar/baz/")
    File.join(["/foo/", "/bar/", nil, "/baz/"]).should eq("/foo/bar/baz/")
  end

  it "gets stat for this file" do
    stat = File.stat(__FILE__)
    stat.blockdev?.should be_false
    stat.chardev?.should be_false
    stat.directory?.should be_false
    stat.file?.should be_true
  end

  it "gets stat for this directory" do
    stat = File.stat(__DIR__)
    stat.blockdev?.should be_false
    stat.chardev?.should be_false
    stat.directory?.should be_true
    stat.file?.should be_false
  end

  it "gets stat for a character device" do
    stat = File.stat("/dev/null")
    stat.blockdev?.should be_false
    stat.chardev?.should be_true
    stat.directory?.should be_false
    stat.file?.should be_false
  end

  it "gets stat for open file" do
    File.open(__FILE__, "r") do |file|
      stat = file.stat
      stat.blockdev?.should be_false
      stat.chardev?.should be_false
      stat.directory?.should be_false
      stat.file?.should be_true
    end
  end

  it "gets stat for non-existent file and raises" do
    begin
      File.stat("non-existent")
      fail "expected Errno to be raised"
    rescue Errno
    end
  end

  describe "size" do
    assert { File.size("#{__DIR__}/data/test_file.txt").should eq(240) }
    assert do
      File.open("#{__DIR__}/data/test_file.txt", "r") do |file|
        file.size.should eq(240)
      end
    end
  end

  describe "cmp" do
    it "compares two equal files" do
      File.cmp("#{__DIR__}/data/test_file.txt", "#{__DIR__}/data/test_file.txt").should be_true
    end

    it "compares two different files" do
      File.cmp("#{__DIR__}/data/test_file.txt", "#{__DIR__}/data/test_file.ini").should be_false
    end
  end
end
