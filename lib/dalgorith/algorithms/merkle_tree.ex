defmodule Dalgorith.MerkleTree do
  @moduledoc """
  A Hash tree or Merkle tree is a tree in which every leaf node is labelled
  with the cryptographic hash of a data block, and every non-leaf node is labelled
  with the cryptographic hash of the labels of its child nodes. A merkle tree is a
  generalization of hash lists and hash chains.
  `https://en.wikipedia.org/wiki/Merkle_tree`

  The usefulness of merkle trees is where data integrity is required like in in blockchain or zfs.
  """

  defstruct root_hash: nil, nodes: [], leaves: []

  defmodule Leaf do
    @moduledoc """
    MerkleTree leaf node
    """
    defstruct hash: nil, value: nil, level: 0
  end

  defmodule Node do
     @moduledoc """
    MerkleTree non-leaf node
    """
    defstruct [:hash, :left, :right, level: 0]
  end

  alias __MODULE__

  # this were some transactions in a bitcoin block
  @tx_hashes [
    "f2287f17a4fa232dca5715c24a92f7112402a8101b9a7b276fb8c8f617376b90",
    "bb5ee510a4fda29cae30c97e7eee80569d3ec3598465f2d7e0674c395e0256e9",
    "647ab8c84365620d60f2523505d14bd230b5e650c96dee48be47770063ee7461",
    "34b06018fcc33ba6ebb01198d785b0629fbdc5d1948f688059158f053093f08b",
    "ff58b258dab0d7f36a2908e6c75229ce308d34806289c912a1a5f39a5aa71f9f",
    "232fc124803668a9f23b1c3bcb1134274303f5c0e1b0e27c9b6c7db59f0e2a4d",
    "27a0797cc5b042ba4c11e72a9555d13a67f00161550b32ede0511718b22dbc2c",
  ]

  @doc """
  Computation of merkle root
  """
  def root_hash(data \\ @tx_hashes)
  def root_hash(data) when length(data) <= 2,
    do: do_bucket(data)
  def root_hash(data) do
    chunk(data)
    |> bucket()
    |> root_hash()
  end

  # defp add_root_hash(tree, data) do
  #   # this should be computed while the leaves and nodes are being added
  #   %{tree | root_hash: root_hash(data)}
  # end


  @doc """
  Building a merkle tree given leaves' data e.g. transactions
  """
  def build_tree(data \\ @tx_hashes)
  def build_tree(data) do
    # chunk(data)
    add_leaves(data)
    |> add_nodes()
    # |> add_root_hash(data)
  end

  def add_leaves(data) do
    make_even(data)
    # |> Enum.reverse()
    |> add_leaf(%MerkleTree{})
  end

  def add_leaf([], tree), do: tree
  def add_leaf([value|rest], tree) do
    leaf = %Leaf{hash: hash(value), value: value}
    add_leaf(rest, %{tree | leaves: [leaf | tree.leaves]})
  end

  def add_nodes(%{leaves: leaves} = tree) do
    chunk(leaves)
    |> do_add_nodes(tree)
    # recursively add higher parent nodes
    |> add_parent_nodes()
  end

  defp add_parent_nodes(tree) do
    chunk(tree.nodes)
    |> do_add_nodes(tree)
  end

  defp do_add_nodes(chunked_nodes, tree) do
    modified_tree = add_node(chunked_nodes, tree)
    top_node = List.first(modified_tree.nodes)
    highest_level_nodes =
      Enum.filter(modified_tree.nodes, & &1.level == top_node.level)

    if length(highest_level_nodes) > 1 do
      chunk(highest_level_nodes)
      |> do_add_nodes(modified_tree)
    else
      modified_tree
    end
  end

  defp add_node([], tree), do: tree
  defp add_node([[f|_] = child_nodes|rest], tree) do
    children_hashes = Enum.map(child_nodes, & &1.hash)
    node = %Node{
      hash: do_bucket(children_hashes),
      left: List.first(child_nodes),
      right: List.last(child_nodes),
      level: f.level + 1
    }

    add_node(rest, %{tree | nodes: [node | tree.nodes]})
  end

  defp make_even(data_array) do
    data_length = length(data_array)
    if rem(data_length, 2) == 0 do
      data_array
    else
      last_item = List.last(data_array)
      List.insert_at(data_array, -1, last_item)
    end
  end

  def get_node(tree, node_hash) do
    tree.nodes
    |> Enum.find(& &1.hash == node_hash)
  end

  def root_node(%{nodes: [root_node | _]}), do: root_node

  #data_array could be any data like transactions or files
  defp chunk(data_array) do
    make_even(data_array)
    |> Enum.chunk_every(2)
  end

  def bucket(chunked_data) do
    chunked_data
    |> Enum.reduce([], fn chnk, acc ->
      [do_bucket(chnk) | acc]
    end)
    |> Enum.reverse()
  end

  defp do_bucket(data_chunk) do
    data_chunk
    |> Enum.map(&hash(&1))
    # handle endianess
    |> Enum.join()
    |> hash()
  end

  def hash(data, _rounds \\ 2) do
    # build leaf, parent and root hash nodes
    :crypto.hash(:sha256, data)
    |> Base.encode16()
    |> String.downcase()
  end
end
