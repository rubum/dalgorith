defmodule Dalgorith.BinaryTree do
  @moduledoc """
  Binary Tree algorithm
  """

  defmodule Node do
    defstruct data: nil, left: nil, right: nil
  end

  @doc """
  Insertion of multiple values from a list using inorder traversal
  """
  def multi_insert(node \\ %Node{}, data_list) do
    Enum.reduce(data_list, node, &insert(&2, &1))
  end

  @doc """
  Adding data to a tree
  """
  def insert(root_node \\ %Node{}, data_item)
  def insert(%{data: nil} = root, data), do: %{root | data: data}
  def insert(%{data: rdata} = root, data) when rdata == data, do: root
  def insert(root, data), do: do_insert(root, data)

  defp do_insert(%{left: nil, data: node_data} = node, data)
    when data < node_data do
    %{node | left: %Node{data: data}}
  end

  defp do_insert(%{left: _, data: ndata} = node, data) when ndata == data, do: node
  defp do_insert(%{left: left_node, data: node_data} = node, data)
    when data < node_data do
    %{node | left: do_insert(left_node, data)}
  end

  defp do_insert(%{right: _, data: ndata} = node, data) when ndata == data, do: node
  defp do_insert(%{right: nil, data: root_data} = node, data)
    when data > root_data do
    %{node | right: %Node{data: data}}
  end

  defp do_insert(%{right: right_node, data: node_data} = node, data)
    when data > node_data do
    %{node | right: do_insert(right_node, data)}
  end
end
