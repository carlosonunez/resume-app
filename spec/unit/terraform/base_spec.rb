# frozen_string_literal: true

require 'spec_helper'

describe 'Given a repository of Terraform configuration code',
         terraform: true do
  context 'When I generate a plan' do
    it 'It should not generate an empty plan' do
      expect(@terraform_plan.empty?).to be false
    end
  end
end
