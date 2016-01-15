# coding: utf-8
require 'spec_helper'

module TfIdfSimilarity
  describe Token do
    describe '#valid?' do
      it 'should return false if all of its characters are numbers, punctuation or whitespace characters' do
        Token.new('1 2 3 ! @ #').valid?.should == false
      end

      it 'should return true if not all of its characters are numbers, punctuation or whitespace characters' do
        Token.new('1 2 3 ! @ # a').valid?.should == true
      end
    end

    describe '#lowercase_filter' do
      it 'should lowercase the token' do
        Token.new('HÉTÉROGÉNÉITÉ').lowercase_filter.should == 'hétérogénéité'
      end
    end

    describe '#classic_filter' do
      it 'should remove all periods' do
        Token.new('X.Y.Z.').classic_filter.should == 'XYZ'
      end

      it 'should remove ending possessives' do
        Token.new("foo's").classic_filter.should == 'foo'
      end

      it 'should remove ending possessives with nonstandard apostrophe 1' do
        Token.new("foo`s").classic_filter.should == 'foo'
      end

      it 'should remove ending possessives with nonstandard apostrophe 2' do
        Token.new("foo’s").classic_filter.should == 'foo'
      end

      it 'should not remove infix possessives' do
        Token.new("foo's bar").classic_filter.should == "foo's bar"
      end
    end
  end
end
