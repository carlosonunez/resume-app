require 'spec_helper'
require_relative '../../../lib/rake/helpers/json.rb'

describe 'Given a JSON/Hash template generator' do
  before(:each) do
    @items_to_replace = {
      'foo' => 'bar',
      'baz' => 'quux'
    }
    @empty_template = {}
    @template = {
      'first_item' => '$__FOO__',
      'second_item' => {
        'first_subitem' => 'bar',
        'second_subitem' => %w[
          baz
          quux
        ]
      },
      'third_item' => [
        {
          'first_item' => '$__BAZ__',
          'second_item' => 'baz'
        },
        {
          'first_item' => 'quux',
          'second_item' => [
            'foo',
            'bar',
            'quux: $__BAZ__'
          ]
        }
      ]
    }
    @expected_template = {
      'first_item' => 'bar',
      'second_item' => {
        'first_subitem' => 'bar',
        'second_subitem' => %w[
          baz
          quux
        ]
      },
      'third_item' => [
        {
          'first_item' => 'quux',
          'second_item' => 'baz'
        },
        {
          'first_item' => 'quux',
          'second_item' => [
            'foo',
            'bar',
            'quux: quux'
          ]
        }
      ]
    }
  end
  context 'When we provide an empty Hash' do
    it 'It should return an empty Hash' do
      expect { JSONHelpers.create_hash_from_template(@template,
                                                     @template_values)}.empty?
      .to be_true
    end
  end

  context 'When we provide a Hash with templates' do
  end
end
